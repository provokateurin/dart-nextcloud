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

To get started you need a running Nextcloud test instance with the Talk app
enabled.

Then configure and run the tests:

* Copy `config.example.json` to `config.json`
* Configure details in `config.json`
  * `host`: host of the Nextcloud instance
  * `username`: user for tests
  * `password`: user's password
  * `shareUser`: user to share test file with
  * `testDir`: full webdav path to directory for tests, writeable by the user
  * `image`: relatuve path to test image based on user's root
* Run tests with `pub run test` or your IDE
