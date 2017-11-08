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
      <port id="pBody" component="context1"/>
      <context id="context1">
         <port id="pContext" component="media1"/>
         <media id="media1" src="medias/image1.jpg">
            <property name="explicitDur" value="5s"/>
         </media>
         <media id="media2" src="medias/image2.jpg">
            <property name="explicitDur" value="5s"/>
         </media>
         <media id="media3" src="medias/image3.jpg">
            <property name="explicitDur" value="5s"/>
         </media>
         <media id="media4" src="medias/image4.jpg">
            <property name="explicitDur" value="5s"/>
         </media>
         <link xconnector="OnEndStart">
            <bind role="onEnd" component="media1" >
            </bind>
            <bind role="start" component="media2">
            </bind>
         </link>
         <link xconnector="OnEndStart">
            <bind role="onEnd" component="media2" >
            </bind>
            <bind role="start" component="media3">
            </bind>
         </link>
         <link xconnector="OnEndStart">
            <bind role="onEnd" component="media3" >
            </bind>
            <bind role="start" component="media4">
            </bind>
         </link>
      </context>
   </body>
</ncl>