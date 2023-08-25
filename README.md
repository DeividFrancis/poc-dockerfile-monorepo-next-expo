# poc-dockerfile-monorepo-next-expo

POC para gerar dockerfile para produção com foco no monorepo.

> O Foco e no build docker do next então para este teste nao foi tentado executar o projeto `native`


- Construir imagem
```sh
docker build -t turbodocker .

```


- Rodando imagem
```sh
docker run -d -p 3001:3000 turbodocker
```

### Referencias

- https://medium.com/geekculture/optimally-dockerizing-nextjs-application-and-lessons-learned-af1833e7da46
- https://turbo.build/repo/docs/handbook/deploying-with-docker

