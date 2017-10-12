4-ok.sncl
<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
   <head>
      <connectorBase>
      <causalConnector id="OnBeginNStart">
         <simpleCondition role="onBegin"  max="unbounded" qualifier="and"/>
         <simpleAction role="start" />
      </causalConnector>
      </connectorBase>
   </head>
   <body>
      <media id="m1" type="text/html">
      </media>
      <media id="m2" type="text/html">
      </media>
      <media id="m3" type="text/html">
      </media>
      <link xconnector="OnBeginNStart">
         <bind role="onBegin" component="m1" >
         </bind>
         <bind role="onBegin" component="m2" >
         </bind>
         <bind role="start" component="m3">
         </bind>
      </link>
   </body>
</ncl>
