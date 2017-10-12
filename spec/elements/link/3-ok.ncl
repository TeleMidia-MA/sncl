3-ok.sncl
<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
   <head>
      <connectorBase>
      <causalConnector id="OnBeginStartN">
         <connectorParam name="delay"/>
         <simpleCondition role="onBegin" />
         <simpleAction role="start"  max="unbounded" qualifier="par" delay="$delay"/>
      </causalConnector>
      </connectorBase>
   </head>
   <body>
      <media id="m1" type="text/html">
      </media>
      <media id="m2" type="text/html">
      </media>
      <link xconnector="OnBeginStartN">
         <bind role="onBegin" component="m1" >
         </bind>
         <bind role="start" component="m2">
            <bindParam name="delay" value="10s"/>
         </bind>
         <bind role="start" component="m2">
            <bindParam name="delay" value="20s"/>
         </bind>
      </link>
   </body>
</ncl>
