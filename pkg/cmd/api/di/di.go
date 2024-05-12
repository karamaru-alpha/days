package di

import (
	"net/http"

	"go.uber.org/fx"

	api_config "github.com/karamaru-alpha/hoodie/config/api"
	"github.com/karamaru-alpha/hoodie/pkg/cmd/api"
)

func Initialize() fx.Option {
	return fx.Options(
		// DI
		basicOption(),
		// Hooks
		hooks(),
	)
}

func basicOption() fx.Option {
	return fx.Options(
		fx.Provide(
			api.NewServer,
			api_config.New,
			newHandlerOption,
			newServeMux,
		),
		handlerSet,
	)
}

func hooks() fx.Option {
	return fx.Options(
		fx.Invoke(invokeHandler),
		fx.Invoke(func(lc fx.Lifecycle, s *http.Server) {
			lc.Append(fx.StartStopHook(api.Serve(s)))
		}),
	)
}