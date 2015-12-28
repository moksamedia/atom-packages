MAIN PROCESS
------------
---
### main.coffee (browser)

* parses command line args and creates AtomApplication (line 39) by calling AtomApplication.open(args)

### atom-application.coffee (browser)

- open(options) method
    - "static" factory method where actual AtomApplication object is created
    - registers 'application:*' events
    - checks if app is running tests, opening a file, or opening a url
    - openPaths() is the method that opens files
        - requires the src/initialize-application-window.coffee script, which is passed on to the AtomWindow obj
        - either creates a new AtomWindow with the locations to open or tells an existing window to open the locations

### atom-window.coffee

- creates the BrowserWindow object
- collects the load settings
- tells the browser window to load the static/index.html file, passing the load settings as url encoded json
* **THIS KICKS OFF THE SEPARATE RENDER PROCESS**

RENDER PROCESS
--------------
---
### index.html

- basically just an html shell that calls index.js

### index.js

- entry point for the render process
- receives the encoded load settings from the main process (via atom-application and atom-window) in the query string
- pre-load:
    - parses load settings
    - sets the process.env.ATOM_HOME global var as passed in via load settings
    - sets window background styling
- onLoad()
    - creates the FileSystemBlobStore blobStore for path ATOM_HOME/blob-store
    - calls setupWindow(loadsSettings), which:
        - sets up caches and crash reporter
        - retrieves the initialize-application-window.coffee script from loadSettings.windowInitializationScript
        - runs the initialize script, passing in the blobStore

### initialize-application-window.coffee (render, in src directory)

- creates the AtomEnvironment
- creates the ApplicationDelegate object
- assigns the AtomEnvironment object to 'window.atom' in the global context and assigns the ApplicationDelegate object to the applicationDelegate property of the AtomEnvironment
- calls atom.displayWindow(), which sets window dimensions, shows the window, and sets it to have focus
    - displayWindow() actually calls the show() method, which calls the applicationDelegate.showWindow() method, which sends an ipc message with the command: ipc.send("call-window-method", "show"). This is received in the browser AtomApplication class, which passes the show command to the appropriate BrowserWindow object
- calls atom.startEditorWindow(), which is where the workspace & editor environment that the user interacts with is created
    - loads default keymaps
    - loads packages
    - adds the workspace view to the document.body
    - activates the loaded packages
    - runs the user init script
    - updates the menu
    - opens an initial empty editor
