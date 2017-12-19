import json
from urllib import request

class TapAWA:
    
    def __init__(self):
        self.movesQuery = "query RhetoricalMoves($input: String!){ moves(text:$input,grammar:\"analytic\") { analytics } }"
        #self.movesQuery = "query RhetoricalMoves($input: String!){ moves(text:$input) { analytics } }"
        self.tapUrl = "http://tap-test.utscic.edu.au/graphql"
    
    def getAnnotationSchemeFromTAP(self,text):
        variables = {'input': text}
        fullQuery = json.dumps({'query': self.movesQuery, 'variables': variables})
        jsonHeader = {'Content-Type':'application/json'}
        
        tapReq = request.Request(self.tapUrl, data = fullQuery.encode('utf8'), headers = jsonHeader)
        tapResponse = ""
        try:
            tapResponse = request.urlopen(tapReq)
            body = tapResponse.read().decode('utf8')           
            return json.loads(body)
        except Exception as e:
            print(e)
            return json.dumps({})