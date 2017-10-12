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
      <link xconnector="OnBeginStart">
         <bind role="onBegin" component="media1" >
         </bind>
         <bind role="start" component="media2">
         </bind>
      </link>
      <link xconnector="OnBeginStart">
         <bind role="onBegin" component="media1" >
         </bind>
         <bind role="start" component="context1" interface="pC1">
         </bind>
      </link>
      <context id="context1">
         <port id="pC1" component="media3"/>
         <media id="media3" src="medias/image3.jpg">
         </media>
         <media id="media4" src="medias/image3.jpg">
         </media>
         <link xconnector="OnBeginStart">
            <bind role="onBegin" component="media3" >
            </bind>
            <bind role="start" component="media4">
            </bind>
         </link>
      </context>
      <port id="pBody" component="media1"/>
      <link xconnector="OnBeginStart">
         <linkParam name="delay" val="20s">
         <bind role="onBegin" component="media1" >
         </bind>
         <bind role="start" component="media2">
            <bindParam name="delay" value="30s"/>
         </bind>
      </link>
      <media id="media1" src="medias/image1.jpg">
      </media>
      <media id="media2" src="medias/image2.jpg">
      </media>
   </body>
</ncl>