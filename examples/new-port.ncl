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
      <context id="c1">
         <media id="media1" src="medias/image1.jpg">
            <property name="right" value="10px"/>
         </media>
         <context id="c2">
            <media id="media3" type="text/html">
            </media>
            <link xconnector="OnBeginStart">
               <bind role="onBegin" component="c2" >
               </bind>
               <bind role="start" component="media3">
               </bind>
            </link>
            <port id="_pmedia3" component="media3"/>
         </context>
         <link xconnector="OnBeginStart">
            <bind role="onBegin" component="media1" >
            </bind>
            <bind role="start" component="c2" interface="_pmedia3">
            </bind>
         </link>
         <port id="_pmedia1" component="media1"/>
      </context>
      <media id="media2" src="medias/image2.jpg">
         <property name="left" value="10px"/>
      </media>
      <link xconnector="OnBeginStart">
         <bind role="onBegin" component="media2" >
         </bind>
         <bind role="start" component="c1" interface="_pmedia1">
         </bind>
      </link>
      <port id="_pmedia2" component="media2"/>
   </body>
</ncl>