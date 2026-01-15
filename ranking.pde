// Classe Ranking
// Registro do ranking (nickname + pontos)

class RegistroRank {
 String nick;
 int pontos;
 RegistroRank(String n, int p) {
  nick = n;
  pontos = p;
 }
}

// Carrega ranking de arquivo (formato: nick;pontos por linha)
void carregarRanking() {
 ranking.clear();
 String[] linhas = null;
 try {
  linhas = loadStrings(rankingFile);
 }
 catch (Exception e) {
 }
 if (linhas == null) return;
 for (String l : linhas) {
  String[] partes = split(l, ';');
  if (partes.length == 2) ranking.add(new RegistroRank(partes[0], int(partes[1])));
 }
}

// Salva ranking ordenado por pontos (decrescente)
void salvarRanking() {
 ranking.sort((a, b) -> b.pontos - a.pontos);
 String[] linhas = new String[ranking.size()];
 for (int i = 0; i < ranking.size(); i++) linhas[i] = ranking.get(i).nick + ";" + ranking.get(i).pontos;
 saveStrings(rankingFile, linhas);
}

// Desenha painel do ranking com os top 10 (ou menos se não houver)
void desenharRanking() {
 for (int i = 0; i < min(10, ranking.size()); i++) {
  RegistroRank reg = ranking.get(i);
  float y = 185 + i * 22;

  // Nicknames + Pontuações
  fill(80);
  textFont(bagel, 18);
  textAlign(LEFT, CENTER);
  text(i + 1 + ". " + reg.nick, width / 2 - 110, y);
  textAlign(RIGHT, CENTER);
  text(reg.pontos, width / 2 + 100, y);
 }
 textAlign(CENTER, CENTER);
}

// Retorna o recorde atual (maior pontuação no ranking)
int obterRecorde() {
 int recorde = 0;
 for (RegistroRank r : ranking) if (r.pontos > recorde) recorde = r.pontos;
 return recorde;
}
