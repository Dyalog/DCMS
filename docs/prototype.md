# Prototype functionality
This system consists of two parts: a backend service and a frontend dashboard
The service will expose a REST API
The front end will connect to the API to allow manually updating data

## to do
- events
- categories
	- remove duplicates

- persons
- presentations
- presenters

- videos
	- fix publishedAt
- updated_at & updated_by
- YouTubeImport

YouTube API: playlists?

- new website: how to deploy?

## Configuration
Configure dependencies and other settings in dev.dcfg and run.dcfg

|Parameter|Description|
|---|---|
|URL|URL of the web service|
|Port|Port of the web service|
|Jarvis|Path to the Jarvis.dyalog class script|
|HttpCommand|Path to the HttpCommand.dyalog class script|

- Set the URL and port of the web service
	**default:** localhost:8080
- Jarvis: path to Jarvis.dyalog class script
- HttpCommand: path to HttpCommand.dyalog class script
- [Jarvis configuration parameters]()

## Development
- `$DYALOG/ocbd.ini.sample`

## Authentication

## Deployment

## Start
Start the service

## Update

## API
A REST API

