moon = require('moon')

import Context, Media, Area from require('presentation')
import Link, Action, Condition from require('link')


media1 = Media("main_media", {src: "imgs/main.jpg", type: "img/jpg"})
area1 = Area("main_area")
context1 = Context("main_context")

context1\addChildren(media1)
media1\addChildren(area1)

condition1 = Condition("onBegin", "media1")
action1 = Action("start", "media1")

link1 = Link()

link1\addAction(action1)
link1\addCondition(condition1)

context1\addChildren(link1)
moon.p context1
print(context1\toNcl!)
