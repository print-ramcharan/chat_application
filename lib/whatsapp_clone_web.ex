defmodule WhatsappCloneWeb do
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: WhatsappCloneWeb.Layouts]

      use Gettext, backend: WhatsappCloneWeb.Gettext
      import Plug.Conn
      unquote(verified_routes())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/whatsapp_clone_web/templates",
        namespace: WhatsappCloneWeb

      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1]

      import Phoenix.HTML
      import WhatsappCloneWeb.ErrorHelpers
      import WhatsappCloneWeb.Gettext
      alias WhatsappCloneWeb.Router.Helpers, as: Routes
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: WhatsappCloneWeb.Endpoint,
        router: WhatsappCloneWeb.Router,
        statics: WhatsappCloneWeb.static_paths()
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
