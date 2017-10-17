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
         <bind role="onEnd" component="video1" >
         </bind>
         <bind role="start" component="video2">
         </bind>
      </link>
      <link xconnector="OnEndStart">
         <bind role="onEnd" component="video2" >
         </bind>
         <bind role="start" component="video1">
         </bind>
      </link>
      <media id="video2" src="medias/night.avi">
      </media>
      <port id="pBody" component="video1"/>
      <media id="video1" src="medias/small.mp4">
      </media>
   </body>
</ncl>