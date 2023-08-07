# Medley

## Prerequisites
* Flutter (https://docs.flutter.dev/get-started/install)
* Python 3 (https://www.python.org/)

## File Structure
```
--- Medley
    |-- client
        |-- ...
        |-- assets            # Custom assets
        |-- lib
            |-- components    # Custom components
                |-- ...
            |-- objects       # Class definitions 
                |-- ...
            |-- providers     # Change notifiers
                |-- ...
            |-- screens       # Screen layouts
                |-- ...
            |-- services      # HTTP requests
                |-- ...
            |-- layout.dart   # Application layout
                |-- ...
            |-- main.dart     # Starts application
                |-- ...
    |-- server
        |-- platforms
            |-- spotify.py    # Spotify-specific code
            |-- youtube.py    # YouTube-specific code
        |-- requirements.txt
        |-- server.py         # Creates endpoints
```

## Client
cd into 'client' directory using cli of choice
### Running
```
flutter pub get
flutter run --release
```

## Server
cd into 'server' directory using cli of choice
### Setting up Virtual Environment
#### Windows
```
python3 -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```
#### Linux/MacOS
```
python3 -m venv venv
source ./venv/bin/activate
pip install -r requirements.txt
```

### Running
```
python3 server.py
```
