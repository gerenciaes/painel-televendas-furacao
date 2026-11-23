# Painel de Televendas — Furacão ES

Aplicação web estática conectada ao Supabase.

## Publicação
O arquivo `index.html` é a aplicação. O repositório pode ser publicado pelo GitHub Pages (Settings → Pages → Deploy from branch → main → /root).

## Preparação obrigatória do Supabase
1. Abra o SQL Editor do projeto Supabase e execute `supabase/schema.sql`.
2. Em Authentication → Users, convide/crie individualmente os seis vendedores e o usuário gestor.
3. Insira os sete registros em `public.profiles`, usando os UUIDs reais de Authentication → Users:
   - vendedores: 1183, 2613, 2638, 2721, 2987, 2999 com perfil `vendedor`;
   - gerente: perfil `gestor`, código nulo.
4. Habilite confirmação/recuperação de e-mail e configure a URL de redirecionamento de autenticação para o endereço publicado.
5. Teste cada conta: vendedor só enxerga seus próprios registros; gestor enxerga a equipe toda e importa a base consolidada.

## Importação
A importação é exclusiva do gestor. A planilha deve conter uma linha por vendedor e colunas equivalentes a:
- Vendedor (código), Meta, Realizado;
- opcional: Dias Úteis, Dias Trabalhados, Carteira/Clientes Ativos, Positivados, Contatos Ativos, Contatos Inativos, Reativados.
A coluna T de contato não é usada.
A carga salva um snapshot por vendedor/data (upsert), não um histórico de vendas diárias. A coluna Realizado é tratada como faturamento consolidado do período informado.

## Segurança
- O navegador usa somente a chave publicável (anon/publishable).
- RLS limita leitura de vendedor ao próprio perfil e libera visão global ao gestor.
- Somente gestor pode importar/alterar lançamentos e administrar perfis.
- Nunca exponha a chave `service_role` no HTML.
