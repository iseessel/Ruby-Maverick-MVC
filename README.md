# README

## Overview
Ruby Maverick(MVC) is a light-weight MVC built in ruby, inspired by Ruby on Rails. This API is currently in production.

## Documentation
### Routes
Ruby Maverick(MVC) routes receive an HTTP request and find the appropriate controller. Maverick(MVC) currently supports GET, POST, PUT, DELETE, and PATCH requests.

- Create a new Router Object. This object will be in charge of handling your routes.
- Draw your routes with the HTTP method, regex object that will match the path,  controller to send the request to, and the appropriate method within the controller
![router](read-me-images/router.png)

### Controllers
Maverick(MVC) controllers are in charge of handling an appropriate HTTP request. All controllers must inherit from ControllerBase; as this will provide each controller with useful methods.

- Create a Controller Class that inherits from ControllerBase
- Create your appropriate controller methods (make sure you have appropriate routes for them!)

#### #render(template_name)
- Sends back a response, rendering the appropriate template found in the file tree: `./views/#controller_name/template_name.html.erb`

#### #redirect_to(url)
- Sends back a response, redirecting the requester to the url.

#### #session
- Creates a session object, consisting of the cookies brought in by our user. We can set our users session cookies using `session[]=` or access into our users session using `session[]`.
