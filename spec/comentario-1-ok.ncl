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
         <bind role="onBegin" component="context1"  interface="pContext1">
         </bind>
         <bind role="start" component="media2">
         </bind>
      </link>
      <port id="pBody" component="media2"/>
      <media id="media2" type="text/html">
      </media>
      <context id="context1">
         <port id="pContext1" component="media1"/>
         <media id="media1" type="text/html">
            <area id="area1" begin="10s">
            </area>
         </media>
      </context>
   </body>
</ncl>