# Youtube API Client Coldfusion

## Usage

```
new Client(api_key[, callTimeout = 5])
```

## Methods

### Playlist

#### `playlistItems`

Parameters :
- required string playlistId,
-  any part
-  numeric max

#### `getLatestVideosOfPlaylist`

Parameters :
- required string playlistId
- numeric max

#### `getRandomVideoOfPlaylist`

Parameters :
- required string playlistId
- numeric max

### Video

#### `videosDetails`

Parameters :
- required string id
- any part

#### `getVideoIdFromUrl`

Parameters:
- required string str

#### `getThumbnailFromUrl`

Parameters :
- required string str
- string quality = 'default'

#### `getThumbnail`

Parameters :
- required string videoId
- string quality = 'default'
