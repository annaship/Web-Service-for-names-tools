var sys = require('sys'),
   http = require('http'),
    net = require('net'),
    url = require('url');


http.createServer(function(request, response){
  var params = url.parse(request.url, true);
  var text = params['query']['text'];

  var words = text.split(' ');
  var found_taxa=[];
  var current_word = 0;

  // Things that TaxonFinder needs
  var current_string = ''
  var current_string_state = '';
  var word_list_matches = 0;

  var sendNextWord = function(){
    var next_word = words[current_word];
    current_word++;

    var input = [next_word, current_string, current_string_state, word_list_matches, 0].join('|');
    stream.write(input+"\r\n");
  };

  var onData = function(data) {
    var response = data.split('|');

    current_string = response[0];
    current_string_state = response[1];
    word_list_matches = response[2];
    var return_string = response[3];
    var return_score  = response[4];
    var return_string_2=response[5];
    var return_score_2= response[6];

    if(return_string) {
      found_taxa.push(return_string);
    }

    if(current_word < words.length)
      sendNextWord();
    else
      stream.end();

  };

  var stream = new net.Stream();
  stream.setEncoding('ascii');
  stream.addListener('connect', sendNextWord);
  stream.addListener('data',    onData);
  stream.addListener('end',     function(){
    response.writeHead(200,{'Content-Type':'text/html'});
    response.write('<h1>Found Taxa</h1><ul>');
    for(var i=0; i<found_taxa.length; i++){
      response.write('<li>' + found_taxa[i] + '</li>');
    }
    response.write('</ul>');
    response.end();
   });
  stream.connect(1234);
}).listen(8080);

    
