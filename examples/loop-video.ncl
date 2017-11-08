<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
   <head>
      <connectorBase>
         <causalConnector id="OnEndStart">
            <simpleCondition role="onEnd" />
            <simpleAction role="start" />
         </causalConnector>
      </connectorBase>
   </head>
   <body>
      <link xconnector="OnEndStart">
         <bind role="onEnd" component="video" >
         </bind>
         <bind role="start" component="video">
         </bind>
      </link>
      <media id="video" src="medias/small.mp4">
      </media>
      <port id="pBody" component="video"/>
   </body>
</ncl>