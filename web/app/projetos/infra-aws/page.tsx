export default function InfraAwsPage() {
  return (
    <div className="space-y-12">
      {/* TÍTULO */}
      <h1 className="text-3xl font-bold">Infraestrutura AWS com Terraform</h1>

      {/* CONTEXTO */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Contexto</h2>
        <p className="text-zinc-400">
          Projeto focado na construção de infraestrutura como código, simulando
          um ambiente real de produção com foco em organização, escalabilidade e
          boas práticas de engenharia.
        </p>
      </section>

      {/* PROBLEMA */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Problema</h2>
        <p className="text-zinc-400">
          Provisionar uma infraestrutura escalável e resiliente na AWS, evitando
          configurações manuais e garantindo reprodutibilidade, controle e
          facilidade de manutenção.
        </p>
      </section>

      {/* SOLUÇÃO */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Solução</h2>
        <p className="text-zinc-400">
          Utilização do Terraform para provisionamento automatizado de recursos
          na AWS, incluindo EC2, Application Load Balancer, Auto Scaling Group e
          controle de acesso via IAM, permitindo um ambiente versionado e
          replicável.
        </p>
      </section>

      {/* ARQUITETURA */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Arquitetura</h2>

        <div className="bg-zinc-900 border border-zinc-800 rounded-lg p-4 text-sm text-zinc-300">
          Usuário → CloudFront (opcional) → Application Load Balancer → EC2
          (Next.js)
        </div>
      </section>

      {/* FLUXO DETALHADO */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Fluxo de requisição</h2>

        <div className="bg-zinc-900 border border-zinc-800 rounded-lg p-4 text-sm text-zinc-300 space-y-2">
          <p>Cliente envia requisição HTTP</p>
          <p>↓</p>
          <p>Application Load Balancer recebe e distribui o tráfego</p>
          <p>↓</p>
          <p>Target Group direciona para instâncias saudáveis</p>
          <p>↓</p>
          <p>EC2 executa a aplicação Next.js</p>
          <p>↓</p>
          <p>Resposta retorna ao cliente</p>
        </div>
      </section>

      {/* RECURSOS */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Recursos utilizados</h2>

        <ul className="text-zinc-400 space-y-2 list-disc ml-5">
          <li>AWS EC2 para execução da aplicação</li>
          <li>Application Load Balancer para distribuição de tráfego</li>
          <li>Auto Scaling Group para escalabilidade</li>
          <li>Security Groups controlando acesso</li>
          <li>IAM Roles para controle de permissões</li>
          <li>S3 para armazenamento (quando aplicável)</li>
        </ul>
      </section>

      {/* INFRA COMO CÓDIGO */}
      <section>
        <h2 className="text-xl font-semibold mb-2">
          Infraestrutura como código
        </h2>

        <p className="text-zinc-400">
          Toda a infraestrutura foi provisionada utilizando Terraform,
          permitindo versionamento, reprodutibilidade e automação do ambiente.
        </p>

        <ul className="text-zinc-400 space-y-2 list-disc ml-5 mt-3">
          <li>Provisionamento automatizado de recursos AWS</li>
          <li>Controle de estado com Terraform</li>
          <li>Facilidade de recriação do ambiente</li>
        </ul>
      </section>

      {/* CONFIABILIDADE */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Foco em confiabilidade</h2>

        <ul className="text-zinc-400 space-y-2 list-disc ml-5">
          <li>
            Separação de responsabilidades entre infraestrutura e aplicação
          </li>
          <li>Uso de Load Balancer para resiliência</li>
          <li>Health checks garantindo disponibilidade</li>
          <li>Estrutura preparada para expansão horizontal</li>
        </ul>
      </section>

      {/* DECISÕES TÉCNICAS */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Decisões técnicas</h2>

        <div className="space-y-4 text-zinc-400">
          <div>
            <p className="font-medium text-white">
              Uso de Application Load Balancer
            </p>
            <p>
              O ALB foi escolhido para distribuir o tráfego entre instâncias,
              suportar health checks e permitir evolução futura com roteamento
              baseado em regras.
            </p>
          </div>

          <div>
            <p className="font-medium text-white">
              Separação entre infraestrutura e aplicação
            </p>
            <p>
              A infraestrutura foi isolada utilizando Terraform enquanto a
              aplicação permanece independente, permitindo versionamento
              separado e maior controle.
            </p>
          </div>

          <div>
            <p className="font-medium text-white">Uso de Terraform</p>
            <p>
              Terraform foi adotado para garantir reprodutibilidade do ambiente,
              versionamento da infraestrutura e facilidade de provisionamento em
              diferentes ambientes.
            </p>
          </div>
        </div>
      </section>

      {/* STACK */}
      <section>
        <h2 className="text-xl font-semibold mb-2">Stack</h2>

        <p className="text-zinc-400">
          Terraform • AWS • EC2 • ALB • Auto Scaling • IAM
        </p>
      </section>

      {/* LINKS */}
      <section>
        <a
          href="https://github.com/joaoVitorDS12/AWS-Infrastructure-With-Terraform"
          target="_blank"
          className="mt-6 text-sm border border-zinc-700 px-4 py-2 rounded hover:bg-zinc-800 transition"
        >
          Ver código no GitHub
        </a>
      </section>
    </div>
  );
}
