class Presentation
   -- Extends: Media, Context, Area
   new:(id) =>
      if __DEBUG__
         print("Creating ", @__class.__name)
      assert id != nil
      @id = id

   addProperty:(name, value) =>
      return true

   getProperty:(name) =>
      return true

   addAttribute:(name, value) =>
      assert(@@attributes[name],
         "Invalid attribute #{name} on #{@__class.__name} #{@id}")
      if @attributes == nil
         @attributes = {}
      @attributes[name] = value

   getAttribute:(name) =>
      if @attributes[name]
         return @attributes[name]
      return false

   addChildren:(child) =>
      assert(@@children[child.__class.__name],
         "#{child.__class.__name} cannot be children of #{@__class.__name}")
      if not @children
         @children = {}
      if child.__class.__name == "Link"
         table.insert(@children, child)
      else
         @children[child.id] = child

   toNcl:(indent="") =>
      local attributes_ncl
      if @attributes
         attributes_ncl = ""
         for k, v in pairs(@attributes)
            attributes_ncl ..= " \"#{k}=#{v}\""

      local child_ncl
      if @children
         child_ncl = ""
         for k, v in pairs(@children)
            child_ncl ..= v\toNcl(indent.."   ")

      return "\n#{indent}<#{@__class.__name\lower!} id=\"#{@id}\"#{if attributes_ncl then attributes_ncl else "" }>#{if child_ncl then child_ncl else ""}\n#{indent}</#{@__class.__name\lower!}>"


class Context extends Presentation
   @@attributes = {"refer": true}
   @@children = {"Context": true, "Media":true, "Link": true}

   new:(id, attributes) =>
      super(id)
      if attributes
         for k, v in pairs(attributes)
            super\addProperty(k, v)


class Media extends Presentation
   @@attributes = {"src": true, "type": true, "refer": true, "instance": true, "descriptor": true}
   @@children = {"Area": true}

   new:(id, attributes) =>
      super(id)
      if attributes
         for k, v in pairs(attributes)
            super\addAttribute(k, v)


class Area extends Presentation
   @@attributes = {"coords":true, "begins":true, "end":true, "beginText":true,
      "endText":true, "beginPosition":true, "endPosition":true, "first":true,
      "last":true, "label":true, "clip":true}
   @@children = nil

   new:(id, attributes) =>
      super(id)
      if attributes
         for k, v in pairs(attributes)
            super\addAttribute(k, v)

{:Context, :Media, :Area}
