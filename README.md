# Oicana Example Ruby on Rails

Small example Ruby web service with [Ruby on Rails](https://rubyonrails.org/) that uses Oicana for PDF templating.

## Getting Started

1. Install dependencies: `bundle install`
2. Start the service: `bin/rails server`
3. Visit http://127.0.0.1:3007/api-docs for the Swagger documentation

The templates are loaded on first use instead of during boot, because Oicana cannot compile in a process forked from one that already compiled. That way, every Puma worker loads its own templates.

The OpenAPI document is generated from the request specs with [rswag](https://github.com/rswag/rswag). Run `bin/rails rswag:specs:swaggerize` after changing them, and `bin/ci` to run all checks.

## Licensing

The code of this example project is licensed under the [MIT license](LICENSE).

But please be aware, that the Oicana dependency [is licensed under PolyForm Noncommercial License 1.0.0][oicana-license] and, after 30 days, requires a commercial license for use cases that are not covered by the PolyForm license. Visit [the Oicana website][oicana-website] for pricing options.


[oicana-license]: https://github.com/oicana/oicana?tab=readme-ov-file#licensing
[oicana-website]: https://oicana.com
