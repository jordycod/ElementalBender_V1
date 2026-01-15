// ParticleMotion.pde
// Classe ParticleMotion
// - Simula um campo de velocidade discreto (grid N x N) e partículas transportadas por esse campo.
// - Recebe movimentos das juntas (mãos/pés) via addForcesFromJoints(...) e injeta forças no campo.
// - Chamando updateAndDraw() dentro do draw() do sketch as partículas são atualizadas e desenhadas.

// ===================================================================
// Definição da classe e variáveis internas
// ===================================================================
class ParticleMotion {
 // Resolução do grid (N x N) e tamanho do array (inclui margem)
 int N, s, np;
 // Campos do fluido/discreto: u = velocidade x por célula, v = velocidade y por célula
 float[] u, v;
 // Partículas: posições, velocidades e "carga" (opcional)
 float[] px, py, vx, vy, ch;

 // Parâmetros de simulação
 float visc = 0.0009; // viscosidade/atenuação do campo
 float dt = 1.0/60.0;  // passo temporal (não crítico aqui)
 float vs = 5; // fator de transporte aplicado às partículas pelo campo
 float r = 1;  // raio visual / margem de colisão simplificada

 // Dimensões da área (largura/altura onde as partículas existem)
 int W, H;

 // Histórico da última posição das juntas para computar deltas (velocidade do movimento)
 ArrayList<PVector> prevJoints;

 // ===================================================================
 // Construtor
 // - N_: resolução do grid, np_: número de partículas, w/h: dimensões da área
 // ===================================================================
 ParticleMotion(int N_, int np_, int w, int h) {
  N = N_;
  np = np_;
  W = w;
  H = h;

  // tamanho do array incluindo margens (N+2)^2
  s = (N + 2) * (N + 2);

  // inicializa arrays do fluido e partículas
  u = new float[s];
  v = new float[s];
  px = new float[np];
  py = new float[np];
  vx = new float[np];
  vy = new float[np];
  ch = new float[np];
  prevJoints = new ArrayList<PVector>();

  // popula partículas em posições aleatórias dentro da área
  for (int i = 0; i < np; i++) {
 px[i] = random(W);
 py[i] = random(H);
 vx[i] = vy[i] = 0;
 ch[i] = 0.5; // carga inicial (pode ser usada para interações eletrostáticas)
  }
 }

 // Reseta histórico de juntas (usar ao entrar no modo FIRE para evitar deltas grandes)
 void resetPrevJoints() {
  prevJoints.clear();
 }

 // ===================================================================
 // Helpers de índice
 // - Converte coordenadas de célula (x,y) para índice no array linear
 // - Garante limites com constrain(...)
 // ===================================================================
 int IX(int x, int y) {
  x = constrain(x, 0, N+1);
  y = constrain(y, 0, N+1);
  return x + (N + 2) * y;
 }

 // ===================================================================
 // Solver (difusão aproximada)
 // - resolve uma equação de difusão/relaxação por iterações (Gauss-Seidel)
 // - b é o tipo de fronteira (usado por set_bnd)
 // ===================================================================
 void solve(int b, float[] x, float[] x0, float a) {
  a *= dt * N * N;
  for (int k = 0; k < 20; k++) {
 for (int i = 1; i <= N; i++) {
  for (int j = 1; j <= N; j++) {
 x[IX(i,j)] = (x0[IX(i,j)] + a*(x[IX(i-1,j)]+x[IX(i+1,j)]+x[IX(i,j-1)]+x[IX(i,j+1)])) / (1 + 4*a);
  }
 }
 set_bnd(b, x);
  }
 }

 // ===================================================================
 // Project
 // - Torna o campo aproximadamente divergência-zero
 // - Método padrão em simulações de fluidos discretos
 // ===================================================================
 void project(float[] u_, float[] v_) {
  float[] p = new float[s];
  float[] div = new float[s];

  // calcula divergência aproximada
  for (int i = 1; i <= N; i++) {
 for (int j = 1; j <= N; j++) {
  div[IX(i,j)] = -0.5f / N * (u_[IX(i+1,j)] - u_[IX(i-1,j)] + v_[IX(i,j+1)] - v_[IX(i,j-1)]);
 }
  }

  set_bnd(0, div);
  set_bnd(0, p);
  solve(0, p, div, 1.0f);

  // corrige velocidades subtraindo gradiente de p
  for (int i = 1; i <= N; i++) {
 for (int j = 1; j <= N; j++) {
  u_[IX(i,j)] -= 0.5f * N * (p[IX(i+1,j)] - p[IX(i-1,j)]);
  v_[IX(i,j)] -= 0.5f * N * (p[IX(i,j+1)] - p[IX(i,j-1)]);
 }
  }
  set_bnd(1, u_);
  set_bnd(2, v_);
 }

 // ===================================================================
 // set_bnd
 // - Aplica condições de contorno simples para o campo (espelhamento/negativo)
 // - Ajusta também os cantos (média simples)
 // ===================================================================
 void set_bnd(int b, float[] x) {
  for (int i = 1; i <= N; i++) {
 x[IX(0, i)] = (b==1) ? -x[IX(1,i)] : x[IX(1,i)];
 x[IX(N+1, i)]  = (b==1) ? -x[IX(N,i)] : x[IX(N,i)];
 x[IX(i, 0)] = (b==2) ? -x[IX(i,1)] : x[IX(i,1)];
 x[IX(i, N+1)]  = (b==2) ? -x[IX(i,N)] : x[IX(i,N)];
  }
  // Cantos: aproximação simples por média de vizinhos
  x[IX(0,0)] = 0.5*(x[IX(1,0)] + x[IX(0,1)]);
  x[IX(0,N+1)] = 0.5*(x[IX(1,N+1)] + x[IX(0,N)]);
  x[IX(N+1,0)] = 0.5*(x[IX(N,0)] + x[IX(N+1,1)]);
  x[IX(N+1,N+1)] = 0.5*(x[IX(N,N+1)] + x[IX(N+1,N)]);
 }

 // ===================================================================
 // addForcesFromJoints
 // - Recebe uma lista de posições projetadas das juntas (em pixels)
 // - Calcula delta (cur - prev) para cada junta e injeta esse delta no campo u/v
 // - Usa prevJoints para suavizar e evitar picos no primeiro frame
 // ===================================================================
 void addForcesFromJoints(ArrayList<PVector> joints) {
  // Se o histórico não tem o mesmo número de juntas, inicializa prevJoints
  if (prevJoints.size() != joints.size()) {
 prevJoints.clear();
 for (int i = 0; i < joints.size(); i++) {
  prevJoints.add(joints.get(i).copy());
 }
 return; // sem delta no primeiro frame para evitar jumps
  }

  float cellW = (float)W / N;
  float cellH = (float)H / N;

  // Para cada junta: calcule movimento e injete no bucket de célula correspondente
  for (int k = 0; k < joints.size(); k++) {
 PVector cur = joints.get(k);
 PVector prev = prevJoints.get(k);
 if (cur == null || prev == null) continue;

 // Se leitura inválida (NaN) atualiza histórico e pula
 if (Float.isNaN(cur.x) || Float.isNaN(cur.y) || Float.isNaN(prev.x) || Float.isNaN(prev.y)) {
  prev.set(cur);
  continue;
 }

 // Delta de movimento da junta (em pixels)
 float mdX = cur.x - prev.x;
 float mdY = cur.y - prev.y;

 // Determina célula do grid onde o movimento ocorreu
 int cx = floor(cur.x / cellW);
 int cy = floor(cur.y / cellH);
 int idx = IX(cx+1, cy+1);

 // Injeta parte do delta no campo u/v usando lerp para suavidade
 if (idx >= 0 && idx < s) {
  u[idx] = lerp(mdX, u[idx], 0.85);
  v[idx] = lerp(mdY, v[idx], 0.85);
 }

 // Atualiza histórico para o próximo frame
 prev.set(cur);
  }
 }

 // ===================================================================
 // updateAndDraw
 // - Resolve o campo (solve/project), aplica transporte nas partículas,
 //  limita movimento nas bordas e desenha as partículas.
 // - Deve ser chamado dentro do draw() do sketch principal.
 // ===================================================================
 void updateAndDraw() {
  // 1) Resolver/difundir campo de velocidades
  solve(1, u, u, visc);
  solve(2, v, v, visc);
  project(u, v);

  // 2) Atualizar e desenhar partículas
  float cw = (float)W / N;
  float ch_h = (float)H / N;

  //noStroke();
  stroke(255, 165, 0, 30);
  fill(255, 255, 0, 30); // cor semitransparente das partículas (ajustável)
  for (int i = 0; i < np; i++) {
 // colisão simples com paredes (inverte velocidade com perda)
 if (px[i] < r || px[i] > W - r) vx[i] *= -0.98;
 px[i] = constrain(px[i], r, W - r);
 if (py[i] < r || py[i] > H - r) vy[i] *= -0.98;
 py[i] = constrain(py[i], r, H - r);

 // influencia do campo (interpolação bilinear simplificada)
 int cX = floor(px[i] / cw);
 int cY = floor(py[i] / ch_h);
 float xr = (px[i] % cw) / cw;
 float yr = (py[i] % ch_h) / ch_h;

 // índices seguros nas quatro células vizinhas
 int ix00 = IX(constrain(cX, 0, N+1), constrain(cY, 0, N+1));
 int ix10 = IX(constrain(cX+1, 0, N+1), constrain(cY, 0, N+1));
 int ix01 = IX(constrain(cX, 0, N+1), constrain(cY+1, 0, N+1));
 int ix11 = IX(constrain(cX+1, 0, N+1), constrain(cY+1, 0, N+1));

 // interpola u e v nas quatro células e aplica ao transporte
 float du = lerp(lerp(u[ix00], u[ix10], xr), lerp(u[ix01], u[ix11], xr), yr);
 float dv = lerp(lerp(v[ix00], v[ix10], xr), lerp(v[ix01], v[ix11], xr), yr);

 px[i] += du * vs;
 py[i] += dv * vs;

 // Aqui mantemos interações de partículas simples (sem O(n^2))
 // Aplica velocidade individual e desenha
 px[i] += vx[i] / 30.0;
 py[i] += vy[i] / 30.0;

 // Desenha partícula como círculo (r raio)
 ellipse(px[i], py[i], r * 2, r * 2);
  }
 }
}
