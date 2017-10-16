<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
   <head>
      <regionBase>
         <region id="region1" top="10%" right="10%" left="10%" bottom="10%">
         </region>
      </regionBase>
      <descriptorBase>
         <descriptor id="region1Desc" region="region1">
         </descriptor>
      </descriptorBase>
      <connectorBase>
         <causalConnector id="OnEndNStart">
            <simpleCondition role="onEnd"  max="unbounded" qualifier="and"/>
            <simpleAction role="start" />
         </causalConnector>
         <causalConnector id="OnEndStart">
            <connectorParam name="delay"/>
            <simpleCondition role="onEnd" />
            <simpleAction role="start"  delay="$delay"/>
         </causalConnector>
      </connectorBase>
   </head>
   <body>
      <link xconnector="OnEndNStart">
         <bind role="onEnd" component="media1" >
         </bind>
         <bind role="onEnd" component="media2" >
         </bind>
         <bind role="start" component="media3">
         </bind>
      </link>
      <link xconnector="OnEndStart">
         <linkParam name="delay" value="10s"/>
         <bind role="onEnd" component="media1" >
         </bind>
         <bind role="start" component="context1" interface="pContext1">
            <bindParam name="delay" value="20s"/>
         </bind>
      </link>
      <media id="media2" src="medias/image1.jpg" type="text/html">
      </media>
      <port id="pBody" component="media1"/>
      <context id="context1">
         <port id="pContext1" component="context1media1"/>
         <media id="context1media1" src="medias/image1.jpg" type="text/html">
         </media>
         <media id="context1media2" src="medias/image1.jpg" type="image/jpeg">
         </media>
         <media id="context1media3" src="medias/image1.jpg" type="text/html">
         </media>
         <link xconnector="OnEndStart">
            <bind role="onEnd" component="context1media1" >
            </bind>
            <bind role="start" component="context1media2">
            </bind>
         </link>
         <link xconnector="OnEndNStart">
            <bind role="onEnd" component="context1media1" >
            </bind>
            <bind role="onEnd" component="context1media2" >
            </bind>
            <bind role="start" component="context1media3">
            </bind>
         </link>
      </context>
      <media id="media1" descriptor="region1Desc" src="medias/image1.jpg">
         <area id="area1" end="30s" begin="20s">
         </area>
      </media>
      <media id="media3" src="medias/image1.jpg" type="text/html">
      </media>
   </body>
</ncl>