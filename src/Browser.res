// Bindings to common browser built-in functions

@scope("document") @val @return(nullable) external getElementById: string => option<Dom.element> = "getElementById"

@scope("window") @val external requestAnimationFrame: (float => unit) => int = "requestAnimationFrame"

@get external getClientWidth: Dom.element => int = "clientWidth"
@get external getClientHeight: Dom.element => int = "clientHeight"
@get external getWidth: Dom.element => int = "width"
@get external getHeight: Dom.element => int = "height"
@set external setWidth: (Dom.element, int) => unit = "width"
@set external setHeight: (Dom.element, int) => unit = "height"
