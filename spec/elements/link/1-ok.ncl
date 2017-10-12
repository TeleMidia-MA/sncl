1-ok.sncl
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
      <media id="m1" type="text/html">
      </media>
      <media id="m2" type="text/html">
      </media>
      <link xconnector="OnBeginStart">
         <bind role="onBegin" component="m1" >
         </bind>
         <bind role="start" component="m2">
         </bind>
      </link>
   </body>
</ncl>
