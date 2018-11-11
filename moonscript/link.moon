class Bind
   new:(role, component, attributes) =>
      assert(role != nil, "#{@__class.__name} cannot have empty role")
      assert(component != nil, "#{@__class.__name} cannot have empty component")
      assert(@@roles[role] == true,
         "Role #{role} invalid on component #{@__class.__name}")
      -- TODO: Assert that component exists
      @role = role
      @component = component

   toNcl:(indent) =>
      return "\n#{indent}<bind role=\"#{@role}\" component=\"#{@component}\">"


class Condition extends Bind
   @@roles = {onBegin: true, onEnd: true, onAbort: true, onPause: true, 
      onResume: true, onSelection: true, onAbortSelection: true, onEndSelection: true,
      onBeginSelection: true, onPauseSelection: true, onResumeSelection: true,
      onBeginAttribution: true, onEndAttributions: true, onPauseAttribution: true,
      onResumeAttribution: true, onAbortAttribution: true}

   @@attributes = {delay: true, eventType: true, key: true, transition: true,
      min: true, max: true, qualifier: true}

   new:(role, component, attributes) =>
      super(role, component)


class Action extends Bind
   @@roles = {start: true, stop: true, pause: true, abort: true, resume: true, set: true}
   @@attributes = {delay: true, eventType: true, actionType: true, value: true,
      min: true, max: true, qualifier: true, repeat: true, repeatDelay: true, 
      duration: true, by: true}

   new:(role, component, attributes) =>
      super(role, component)


class Link
   -- TODO: Gerar Conector
   -- TODO: Gerar xconnector
   @@children = {"Condition": true, "Action": true}

   new:(condition, action) =>
      if condition then @conditions = {condition}
      if actions then @actions = {action}
      @parameters = {}
      @xconnector = ""

   addCondition:(condition) =>
      if @conditions == nil
         @conditions = {}
      table.insert(@conditions, condition)

   addAction:(action) =>
      if @actions == nil
         @actions = {}
      table.insert(@actions, action)

   createxConnector:() =>
      @xconnector = ""

   toNcl:(indent="") =>
      local children_ncl

      if @actions
         children_ncl = children_ncl or ""
         for _, action in pairs(@actions)
            children_ncl ..= action\toNcl(indent.."   ")

      if @conditions
         children_ncl = children_ncl or ""
         for _, condition in pairs(@conditions)
            children_ncl ..= condition\toNcl(indent.."   ")

      return "\n#{indent}<link>#{children_ncl}\n#{indent}</link>"

{:Link, :Condition, :Action}
