/**
 * @output false
 */
component {

  public function init(
    required string api_key,
    numeric callTimeout = 5
  ) {
    variables.api_url = 'https://www.googleapis.com/youtube/v3/';
    variables.api_key = api_key;
    variables.callTimeout = callTimeout;
    return this;
  }


  // --- playlist

  public struct function playlistItems(required string playlistId, any part, numeric max) {
    var param = {
      'playlistId' = playlistId
    };

    if (isNull(part)) { // snippet,contentDetails,status,id
      param['part'] = 'snippet';
    } else {
      if (isArray(part)) {
        part = arrayToList(part, ',');
      }
      param['part'] = part;
    }

    if (!isNull(max)) {
      param['maxResults'] = max;
    }

    return callAPI('playlistItems', param);
  }

  public array function getLatestVideosOfPlaylist(required string playlistId, numeric max) {
    var res = playlistItems(argumentCollection = arguments);
    var videos = [];
    if (structKeyExists(res, 'items')) {
      for (var i = 1; i <= arrayLen(res.items); i++) {
        var item = res.items[i];
        if (item.snippet.resourceId.kind == 'youtube##video') {
          videos.add(item.snippet);
        }
      }
    }
    return videos;
  }


  // --- Videos

  public array function videosDetails(required id, any part) {
    if (isArray(id)) {
      id = arrayToList(id, ',');
    }

    var param = { 'id' = id };

    if (isNull(part)) {
      param['part'] = 'id,player';
    } else {
      if (isArray(part)) {
        part = arrayToList(part, ',');
      }
      param['part'] = part;
    }

    var res = callAPI('videos', param);
    var videos = [];
    if (isStruct(res) && structKeyExists(res, 'items')) {
      for (var item in res.items) {
        videos.add(item);
      }
    } else {
      throwResult('Invalid result', res);
    }

    return videos;
  }

  public string function getVideoIdFromUrl(required string str) {
    var rgx = '(?:youtube(?:-nocookie)?\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/ ]{11})';
    var m = match(rgx, str);

    if (arrayLen(m)) {
      return m[1];
    }

    return '';
  }

  // --- privates

  private void function throwResult(message, res) {
    throw(message = message, detail = !isNull(res) ? serializeJSON(res) : 'Result is null');
  }

  private any function callAPI(required string methodName, required struct args) {
    args['key'] = variables.api_key;

    var urlStr = variables.api_url & methodName;

    var http = new Http(
      url = urlStr,
      method = "GET",
      charset = "utf-8",
      redirect = false,
      timeout = variables.callTimeout
    );

    for (var k in args) {
      http.addParam(
        type = 'URL',
        name = k,
        value = args[k]
      );
    }

    var result = http.send().getPrefix();

    var content = result.fileContent;
    if( !isSimpleValue(content) ) content = content.toString('utf-8');
    if( isJSON(content) ) content = deserializeJSON(content);

    if( !isStruct(content) ) {
      content = {};
    }

    return content;
  }

  private array function match(required string r, required string str, flags) {
    var Pattern = createObject('java', 'java.util.regex.Pattern');
    if(!isNull(flags)) {
      if(isSimpleValue(flags)) {
        flags = listToArray(flags);
      }
      var flagInt = 0;
      var flagName = '';
      for (flagName in flags)
        flagInt += Pattern[flagName];
      var p = Pattern.compile(r, javacast("int", flagInt));
    } else {
      var p = Pattern.compile(r);
    }
    var m = p.matcher(str);
    var i = 1;
    var res = [];

    if(m.find()) {
      var i = 1;
      while(i <= m.groupCount()) {
        res.add(m.group(i));
        i++;
      }
    }
    return res;
  }

}