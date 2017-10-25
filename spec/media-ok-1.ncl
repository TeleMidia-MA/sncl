<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
   <head>
      <regionBase>
         <region id="region1">
         </region>
      </regionBase>
      <descriptorBase>
         <descriptor id="region1Desc" region="region1">
         </descriptor>
      </descriptorBase>
      <connectorBase>
         <causalConnector id="OnBeginStart">
            <connectorParam name="delay"/>
            <simpleCondition role="onBegin" />
            <simpleAction role="start"  delay="$delay"/>
         </causalConnector>
      </connectorBase>
   </head>
   <body>
      <link xconnector="OnBeginStart">
         <linkParam name="delay" value="10s"/>
         <bind role="onBegin" component="media1" >
         </bind>
         <bind role="start" component="media2">
            <bindParam name="delay" value="20s"/>
         </bind>
      </link>
      <port id="pBody" component="media1"/>
      <media id="media1" descriptor="region1Desc" src="medias/image1.jpg">
         <property name="left" value="50%"/>
         <property name="right" value="70%"/>
         <area id="area1" begin="10s">
         </area>
      </media>
      <media id="media2" src="medias/image2.jpg">
      </media>
   </body>
</ncl>