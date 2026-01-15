## 📋 Visão Geral - 🌊🔥 Elemental Bender

**Elemental Bender** é um jogo experimental que explora as possibilidades de Interfaces Naturais de Usuário (NUI) utilizando o sensor Microsoft Kinect V1 e o ambiente Processing. O jogo oferece duas experiências imersivas:

- **Modo Água (Arcade)**: Um jogo de reflexo onde você controla uma massa de água para interceptar alvos caindo pela tela
- **Modo Fogo (Artístico)**: Uma experiência visual interativa onde seus movimentos controlam partículas de fogo, ideal para apresentações artísticas

---

## 🎮 Características Principais

### Modo Água
- 🎯 Mecânica arcade clássica com dificuldade progressiva
- 💧 Física realista de controle de fluido
- ⚡ Power-up de água dupla a cada 40 pontos
- 📊 Sistema de ranking persistente
- ⏱️ Timer dinâmico com recompensas e penalidades
- 🎨 Feedback visual progressivo (overlay vermelho de erro)

### Modo Fogo
- 🔥 Simulação de fogo baseada no algoritmo Doom Fire Effect
- 👥 Suporte a até 2 usuários simultâneos
- 🎵 Interação com amplitude de áudio do microfone
- 🎨 Tonalidades diferentes por usuário (identificação visual)
- 🖼️ Experiência imersiva para dança e artes marciais

### Interface Gestual
- 🖱️ Cursor controlado pela mão direita
- ⏳ Seleção de botões por hover-time (2.5 segundos)
- ⌨️ Teclado virtual gestual para entrada de nickname
- 📱 Interface minimalista inspirada em jogos arcade
- 🎓 Tutorial interativo obrigatório

---

## 📦 Requisitos

### Hardware Mínimo
- **CPU**: Intel Core i5 (8ª geração) ou AMD Ryzen 5 2600
- **RAM**: 8 GB DDR4
- **GPU**: Intel Integrated Graphics (UHD 630)
- **Espaço**: 1,5 m × 2,0 m mínimo para jogar
- **Sensor**: Microsoft Kinect V1
- **Conexão**: USB 3.0 para Kinect

### Hardware Recomendado
- **CPU**: Intel Core i7 (10ª geração) ou AMD Ryzen 7 3700X
- **RAM**: 16 GB DDR4
- **GPU**: NVIDIA GeForce GTX 1650 ou AMD Radeon RX 6600
- **Espaço**: 3,0 m × 2,0 m
- **Áudio**: Caixas de som externas USB 2.0+

### Software
- **Sistema Operacional**: Windows 10 Home/Pro ou Windows 11 (64-bit)
- **Processing**: 4.0 ou superior (Revisão 4.4.7 testado)
- **Java Runtime**: Java 8 JRE ou superior
- **Kinect SDK**: Microsoft Kinect for Windows SDK v1.8 (15/07/2024)

---

## 🚀 Instalação e Configuração

### 1. Preparar o Ambiente

```bash
# Clonar o repositório
git clone https://github.com/seu-usuario/elemental-bender.git
cd elemental-bender
```

### 2. Instalar Processing

1. Baixe Processing 4.0+ em https://processing.org/download
2. Instale seguindo as instruções do seu SO

### 3. Instalar Bibliotecas do Kinect

No Processing, acesse `Sketch` → `Import Library` → `Manage Libraries` e instale:

- **SimpleOpenNI** (para captura de movimento do Kinect)
- **Sound** (para áudio e análise de amplitude)

### 4. Configurar Drivers do Kinect

1. Baixe o **Kinect for Windows SDK v1.8** em:
   https://www.microsoft.com/en-us/download/details.aspx?id=40278

2. Instale o SDK completo (inclui drivers e ferramentas)

3. Conecte o Kinect V1 via USB 3.0

4. Verifique a conexão aberto o exemplo "Skeleton_Tracking_Demo" em:
   `Sketch` → `Examples` → `Libraries` → `SimpleOpenNI` → `User Tracking`

### 5. Preparar Arquivos de Assets

Crie a pasta `data/` na raiz do projeto com a seguinte estrutura:

```
data/
├── backgrounds/       # Imagens de fundo das telas
├── buttons/          # Ícones e imagens dos botões
├── sprites/          # Gráficos dos alvos e elementos
├── sound/            # Arquivos de áudio (MP3)
├── tutorial/         # Slides do tutorial (PNG)
├── help/             # Recursos de ajuda
└── ranking/          # Dados salvos (criado automaticamente)
```

### 6. Executar o Jogo

```bash
# Abrir o arquivo principal em Processing
# Arquivo: Elemental_Bender.pde (ou main.pde)

# Executar: Pressione Ctrl+R (Windows) ou Cmd+R (Mac)
# Ou clique no botão "Play" na interface
```

---

## 🎯 Como Jogar

### Modo Água (Arcade)

1. **Posicionamento**: Fique a ~1.5-2m de distância do Kinect, com o corpo inteiro visível
2. **Detecção**: Aguarde o cursor aparecer na tela (você foi detectado!)
3. **Controle**: 
   - Mova **ambas as mãos** para controlar a massa de água
   - O ponto médio entre as mãos é o controlador
4. **Objetivo**: Intercepte os **alvos vermelhos** que caem pela tela
5. **Pontuação**:
   - +1 ponto por alvo acertado
   - +1 segundo ao timer por acerto
   - -1 segundo ao timer por alvo perdido
6. **Power-Up**: A cada 40 pontos, controle **duas massas de água** por 15 segundos
7. **Fim**: A partida termina quando o tempo se esgotar

### Modo Fogo (Artístico)

1. **Posicionamento**: Mesmo que o Modo Água
2. **Controle**: 
   - **Mãos e pés** controlam as fontes de fogo
   - Cada usuário tem uma cor diferente
3. **Interação Sonora**: A amplitude do microfone afeta o tamanho das partículas de fogo
4. **Objetivo**: Explorar e criar efeitos visuais com seu movimento

---

## 🕹️ Controles

| Ação | Controle |
|------|----------|
| Mover Cursor | Mover mão direita |
| Selecionar Botão | Manter cursor sobre botão por 2.5s |
| Controlar Água | Mover ambas as mãos (ponto médio) |
| Controlar Fogo | Mover mãos e pés |
| Sair do Jogo | Alt+F4 ou fechar janela |

---

## ⚙️ Configuração Recomendada do Ambiente

### Iluminação
- ✅ **Recomendado**: Iluminação controlada, sem luz solar direta
- ❌ **Evitar**: Ambientes muito escuros ou muito brilhantes

### Vestuário
- ✅ **Recomendado**: Roupas de cores claras ou neutras
- ❌ **Evitar**: Tecidos sintéticos ou cores muito escuras (absorvem infravermelho)

### Espaço Físico
- ✅ **Recomendado**: Área aberta sem móveis
- ❌ **Evitar**: Objetos entre você e o sensor

---

## 🐛 Solução de Problemas

| Problema | Solução |
|----------|---------|
| Kinect não é detectado | Reinstale drivers; verifique conexão USB 3.0 |
| Rastreamento instável | Ajuste iluminação; verifique vestuário |
| FPS baixo (<25) | Reduza qualidade gráfica; feche aplicações |
| Som não funciona | Verifique conexão de áudio; reinstale biblioteca Sound |
| Cursor não aparece | Fique mais perto do Kinect (1.5-2m) |

---

## 📊 Requisitos Funcionais Implementados

- ✅ RF01: Captura de Movimento em tempo real
- ✅ RF02: Rastreamento das Mãos (<200ms)
- ✅ RF03: Seleção de Modo (Água/Fogo)
- ✅ RF04: Emissão de Elementos Visuais
- ✅ RF05: Feedback Visual Instantâneo
- ✅ RF06: Detecção de Alvos e Colisão
- ✅ RF07: Sistema de Pontuação
- ✅ RF08: Encerramento de Partida

---

## 📈 Requisitos Não Funcionais

- ✅ RNF01: Desempenho (>25 FPS Modo Água; >20 FPS Modo Fogo)
- ✅ RNF02: Usabilidade (Interface intuitiva)
- ✅ RNF03: Acessibilidade (Usuários iniciantes)
- ✅ RNF04: Estabilidade (Sem travamentos)
- ✅ RNF05: Precisão de Rastreamento (Consistente)
- ✅ RNF06: Compatibilidade (Windows + Kinect V1)

---

## 🏗️ Arquitetura de Software

O projeto está organizado em módulos independentes:

```
Elemental_Bender/
├── main.pde                  # Entrada principal + loop
├── variables.pde             # Variáveis globais e constantes
├── interface.pde             # Interface gestual e botões
├── bodyTracking.pde          # Rastreamento corporal (Kinect)
├── water.pde                 # Física e lógica da água
├── fire.pde                  # Motor de fogo (Doom Fire Effect)
├── target.pde                # Sistema de alvos e colisões
├── ranking.pde               # Ranking e persistência
├── kinect.pde                # Inicialização do Kinect
├── buttons.pde               # Classe reutilizável ImageButton
├── particleMotion.pde        # Sistema de partículas guiadas
├── resources.pde             # Carregamento de assets
└── data/                     # Imagens, sons e assets
```

---

## 📚 Estrutura de Dados Principal

### Estados do Jogo
```
ESTADO_INTRO          (0) - Tela inicial
ESTADO_MENU           (1) - Menu principal
ESTADO_AGUA           (2) - Modo Água (Arcade)
ESTADO_FOGO           (3) - Modo Fogo (Artístico)
ESTADO_FINAL          (4) - Tela de Game Over
ESTADO_NICK           (5) - Teclado virtual
ESTADO_RANK           (6) - Visualização de ranking
ESTADO_TUTORIAL_SLIDES (7) - Tutorial
```

### Classe Target
```java
class Target {
  float x, y, raio, velocidadeY;
  boolean hit, surprise;
  float raioColisao;
}
```

### Classe RegistroRank
```java
class RegistroRank {
  String nick;
  int pontos;
}
```

---

## 🎨 Design Visual

**Paleta de Cores**:
- Tons terrosos e pastéis
- Azul para elemento Água
- Vermelho/Laranja para elemento Fogo
- Contraste alto para legibilidade

**Fontes**:
- Bagel Fat One (títulos e interface)
- The Last Shuriken (textos dinâmicos)

---

## 🧪 Testes de Usabilidade

O projeto passou por 2 ciclos de testes:

### Teste Alfa (14/10/2025)
- 3 participantes
- Versão MVP com mecânicas básicas
- Identificou problemas de legibilidade e posicionamento

### Teste Beta (04/12/2025)
- 7 participantes universitários
- Versão de alta fidelidade
- Validou mecânicas, performance e interface

**Resultados**: 
- Diversão: 3-5/5
- Performance: 4-5/5
- Legibilidade: 3-5/5

---

## 📖 Documentação Completa

Para documentação técnica detalhada, incluindo:
- Análise de projetos similares
- Fundamentação teórica completa
- Metodologia Design Thinking
- Diagramas de arquitetura
- Referências bibliográficas

Consulte o arquivo: **Elemental_Bender_Relatório_Técnico.docx**

---

## 🤝 Contribuições

Este é um projeto acadêmico de conclusão de curso. Para sugestões e melhorias:

1. Teste o jogo
2. Documente problemas ou ideias
3. Abra uma issue no repositório
4. Ou contacte o desenvolvedor

---

## 📝 Licença

Este projeto é licenciado sob a **Licença MIT** - veja o arquivo `LICENSE` para detalhes.

---

## 👤 Autor

**Jordy Muniz Araújo**

- 🎓 Graduando em Sistemas e Mídias Digitais
- 🏫 Instituto Universidade Virtual (IAUD), UFC
- 📧 Contato via GitHub

**Orientador**: Prof. Dr. Roberto Cesar Cavalcante Vieira

---

## 🙏 Agradecimentos

- Universidade Federal do Ceará (UFC)
- Instituto de Arquitetura e Urbanismo e Design (IAUD)
- Projeto Design Computacional
- Comunidade Processing e SimpleOpenNI
- Todos os participantes dos testes de usabilidade

---

## 📅 Cronograma do Projeto

- **Pesquisa Inicial**: Junho - Julho 2025
- **Prototipação Pré-Alfa**: Agosto - Setembro 2025
- **Teste Alfa**: Outubro 2025
- **Desenvolvimento Beta**: Novembro 2025
- **Teste Beta**: Dezembro 2025
- **Finalização**: Dezembro 2025 - Janeiro 2026

---

## 🔮 Trabalhos Futuros

- 🎮 Modo Multijogador Cooperativo
- 🌍 Expansão para Elementos Terra e Ar
- 🤖 Migração para Machine Learning para reconhecimento de gestos
- ♿ Modo acessível para deficientes visuais (controle por som)
- 📱 Versão Web (p5.js)
- 🎮 Integração com outras plataformas

---

## 📞 Suporte

Para problemas técnicos ou dúvidas:

1. Verifique a seção "Solução de Problemas"
2. Consulte o Relatório Técnico completo
3. Abra uma issue no GitHub
4. Contacte o desenvolvedor

---

**Última atualização**: Janeiro de 2026  
**Versão**: 1.0 Beta

<img width="1090" height="411" alt="LOGOTIPO" src="https://github.com/user-attachments/assets/944f3350-0a69-4c5c-bd93-289c306c15a4" />
<img width="1280" height="720" alt="vlcsnap-2026-01-14-11h58m13s118" src="https://github.com/user-attachments/assets/04fa69ba-ebc6-4b06-8afa-9b7623b4af96" />
<img width="640" height="480" alt="Tela Inicial" src="https://github.com/user-attachments/assets/d5c0cbbb-db36-48da-bed3-6fd14ac75930" />
<img width="1280" height="720" alt="vlcsnap-2026-01-14-09h17m41s586" src="https://github.com/user-attachments/assets/77552c6f-4810-4e48-80d5-aa24f1758c00" />
<img width="1280" height="720" alt="vlcsnap-2026-01-14-10h53m10s710" src="https://github.com/user-attachments/assets/3226d6e5-293f-4b46-9ecb-baec05344f95" />
