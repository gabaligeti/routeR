#' S3 class router
#' @exportClass router
#
router <- function() {

    self <- list(
        GET = list(),
        POST = list(),
        PUT = list(),
        DELETE = list()
    )

    class(self) <- "router"
    return(self)
}

check_rapache <- function() {
    if (!exists("SERVER")) {
        stop("It is not a Rapache environment.")
    }
}

get_params <- function() {

    check_rapache()

    if (SERVER$method == "GET") {
        params <- GET
    }

    if (SERVER$method == "POST") {
        params <- POST
    }

    if (is.null(params)) {
        params <- list()
    }

    return(params)
}

#' A description of add_route
#'
#' A details of add_route
#'
#' @title add_route: add new route to a router
#' @param router router class
#' @param method http verb such "GET", "POST", "PUT" or "DELETE"
#' @param endpoint string e.g. "/add/", slashes are important!!
#' @param fun function
#' @examples
#' r <- router()
#' r <- add_route(r,
#'     method = "GET",
#'     endpoint = "/add/",
#'     fun = function(a, b) {
#'         return(as.numeric(a) + as.numeric(b))
#'     }
#' )
#'
#' @rdname add_route
#' @export add_route
#' @return router
add_route <- function(router, method, endpoint, fun) {
    UseMethod("add_route", router)
}

#' @return \code{Object}
#'
#' @rdname add_route
#' @method add_route default
#' @export add_route default
add_route.default <- function(router, method, endpoint, fun) {
    print("No router object!!!")
    return(router)
}

#' @return \code{Object}
#'
#' @rdname add_route
#' @method add_route router
#' @export add_route router
add_route.router <- function(router, method, endpoint, fun) {

    if (!(method %in% names(router))) {
        stop("Incorrect HTTP verb!")
    }

    router[[method]][[endpoint]] <- fun

    return(router)
}

run <- function(router) {
    UseMethod("run", router)
}

run.default <- function(router) {
    print("Not a router object!!")
    return(router)
}

run.router  <-  function(router) {

    check_rapache()

    method <- SERVER$method
    endpoint <- SERVER$path_info

    controller <- router[[method]][[endpoint]]

    if (!is.function(controller)) {
        setStatus(status=404L)
        cat("No such endpoint.")
        return()
    }

    params <- get_params()

    if (
        !setequal(names(params), names(formals(controller))) ||
        length(names(params)) != length(names(formals(controller)))
    ) {
        setStatus(status=500L)
        cat("Parameters do not match!")
        return()
    }

    result <- do.call(controller, params)

    cat(result)
}
