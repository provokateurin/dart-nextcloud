# nextcloud

A Nextcloud client for dart

## Features

* Creating directories, removing directories and files
* Uploading and downloading files
* Directory listing
* Get a user's full name and the groups the user belongs to
* Move and copy files and folders
* Create shares, update them and delete them. All share types supported (except federate cloud sharing)
* Search for users to share a file or folder with (sharees)
* Create chats with other users, message them and received messages (Talk)
* Search for users to create a chat with
* Get the avatar image of a user

## Usage/Example

[https://github.com/Viktoriaschule/dart-nextcloud/blob/master/example/example.dart](https://github.com/Viktoriaschule/dart-nextcloud/blob/master/example/example.dart)

## Development

You can create a Docker development instance of Nextcloud using `./scripts/run.sh`.  
It already has everything that is necessary installed.  
For credentials and everything else look into the `config.example.json` file.

## Testing

The testing should also be done using the Docker development instance of Nextcloud.  
Copy the `config.example.json` file to `config.json`.

Then run the tests using `./scripts/test.sh`.  
If you only want to run a subset of tests, pass the file names of the tests like this:  
`./scripts/test.sh test/webdav_test.dart test/talk_test.dart`