<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">
   <head>
      <ruleBase>
   <rule id="rEn" var="system.language" comparator="eq" value="en" />
   <rule id="rPt" var="system.language" comparator="eq" value="pt" />
      </ruleBase>
   </head>
   <body>
      <media id="noSettings" type="application/x-ncl-settings">
         <property name="system.language" value="pt"/>
      </media>
      <switch id="form">
         <bindRule constituent="firstImage" rule="rEn"/>
         <bindRule constituent="secondImage" rule="rPt"/>
         <defaultComponent component="firstImage" />

         <media id="firstImage" src="medias/image1.jpg"/>
         <media id="secondImage" src="medias/image2.jpg"/>

      </switch>

      <port id="pBody" component="form"/>
   </body>
</ncl>
