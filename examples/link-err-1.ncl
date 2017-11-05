<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
   <head>
      <connectorBase>
         <causalConnector id="OnEndOnBeginStart">
            <compoundCondition operator="and">
               <simpleCondition role="onEnd" />
               <simpleCondition role="onBegin" />
            </compoundCondition>
            <simpleAction role="start" />
         </causalConnector>
      </connectorBase>
   </head>
   <body>
      <link xconnector="OnEndOnBeginStart">
         <bind role="onEnd" component="media1" >
         </bind>
         <bind role="onBegin" component="media1" >
         </bind>
         <bind role="start" component="media1">
         </bind>
      </link>
      <media id="media1" type="text/html">
      </media>
   </body>
</ncl>