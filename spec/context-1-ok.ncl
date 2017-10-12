<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
   <head>
      <connectorBase>
         <causalConnector id="OnBeginStart">
            <simpleCondition role="onBegin" />
            <simpleAction role="start" />
         </causalConnector>
      </connectorBase>
   </head>
   <body>
      <port id="pBody" component="c1"/>
      <context id="c1">
         <port id="pC1" component="media1"/>
         <media id="media1" src="medias/image1.jpg">
         </media>
         <media id="media2" src="medias/image2.jpg">
         </media>
         <link xconnector="OnBeginStart">
            <bind role="onBegin" component="media1" >
            </bind>
            <bind role="start" component="media2">
            </bind>
         </link>
      </context>
   </body>
</ncl>