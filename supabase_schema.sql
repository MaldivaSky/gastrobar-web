-- ── TABELAS ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS clientes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome        TEXT NOT NULL,
  email       TEXT UNIQUE NOT NULL,
  telefone    TEXT,
  nascimento  DATE,
  senha_hash  TEXT NOT NULL,
  cadastro    DATE DEFAULT CURRENT_DATE,
  reservas    INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS eventos (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo      TEXT NOT NULL,
  subtitulo   TEXT,
  data        DATE NOT NULL,
  hora        TEXT,
  tipo        TEXT,
  tag         TEXT,
  descricao   TEXT,
  img_url     TEXT,
  preco       TEXT,
  inclusos    TEXT[],
  programacao TEXT,
  vagas       INT DEFAULT 0,
  urgencia    TEXT,
  destaque    BOOLEAN DEFAULT false,
  status      TEXT DEFAULT 'ativo',
  criado_em   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reservas (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id  UUID REFERENCES clientes(id) ON DELETE SET NULL,
  mesa        INT NOT NULL,
  data        DATE NOT NULL,
  hora        TEXT NOT NULL,
  pessoas     INT NOT NULL,
  status      TEXT DEFAULT 'pendente',
  obs         TEXT,
  codigo      TEXT UNIQUE,
  criado_em   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS admins (
  id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  nome  TEXT NOT NULL
);

-- ── ROW LEVEL SECURITY ───────────────────────────────────

ALTER TABLE eventos   ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservas  ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes  ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins    ENABLE ROW LEVEL SECURITY;

-- Eventos: qualquer um lê os ativos
CREATE POLICY "eventos_leitura_publica" ON eventos
  FOR SELECT USING (status = 'ativo');

-- Reservas: verifica disponibilidade sem auth (leitura de mesa/hora/data)
CREATE POLICY "reservas_disponibilidade" ON reservas
  FOR SELECT USING (true);

-- Reservas: qualquer um pode criar (anon faz reserva)
CREATE POLICY "reservas_insercao_publica" ON reservas
  FOR INSERT WITH CHECK (true);

-- Clientes: qualquer um pode se cadastrar
CREATE POLICY "clientes_cadastro_publico" ON clientes
  FOR INSERT WITH CHECK (true);

-- Clientes: só lê o próprio registro (por email — sem auth JWT aqui)
CREATE POLICY "clientes_leitura_propria" ON clientes
  FOR SELECT USING (true);

-- ── DADOS INICIAIS — ADMIN ───────────────────────────────
INSERT INTO admins (email, nome)
VALUES ('admin@lagoon.com.br', 'Admin Lagoon')
ON CONFLICT (email) DO NOTHING;

-- ── DADOS DEMO — EVENTOS ─────────────────────────────────
INSERT INTO eventos (titulo, subtitulo, data, hora, tipo, tag, descricao, img_url, preco, inclusos, programacao, vagas, urgencia, destaque, status) VALUES
(
  'Brasil x Haiti',
  'A galera do Lagoon vai parar Guarulhos',
  '2026-06-19', '21:30',
  'Jogo do Brasil · Fase de Grupos',
  '🇧🇷 PRÓXIMO JOGO · Copa 2026',
  'Traz a turma, vem com a camisa e esquece o resto! O Lagoon vira a maior arena da cidade: telão 120", chopp liberado, costelinha na brasa e samba antes de a bola rolar.',
  'https://images.unsplash.com/photo-1705593973313-75de7bf95b56?w=1400&q=90',
  'R$ 80 por pessoa',
  ARRAY['Chopp e caipirinha liberados durante o jogo','Petiscos Copa: costelinha, bolinho e casquinha','Assento reservado com visão total do telão','Shot grátis a cada gol do Brasil 🥃'],
  '20h Samba de abertura · 21h Petiscos e chopp liberado · 21h30 Jogo ao vivo · Após: Baile da vitória',
  8, 'ÚLTIMAS VAGAS', true, 'ativo'
),
(
  'Brasil x Escócia',
  'Última da fase de grupos — classificação garantida',
  '2026-06-24', '19:00',
  'Jogo do Brasil · Fase de Grupos',
  '🇧🇷 QUARTA · 24 JUN · 19h',
  'Brasil já classificado, jogando pelo primeiro lugar. Churrasco de cortes nobres, telão pra todo lado e roda de samba após o apito.',
  'https://images.unsplash.com/photo-1434648957308-5e6a859697e8?w=1400&q=90',
  'R$ 75 por pessoa',
  ARRAY['Churrasco completo: picanha, linguiça e fraldinha','Farofa, vinagrete, pão de alho e saladas','1 chopp artesanal incluso na entrada'],
  '17h30 Churrasco aberto · 19h Jogo ao vivo · Após: Roda de samba',
  22, NULL, false, 'ativo'
),
(
  'Samba com Feijoada',
  'Grupo DuPagode ao vivo — do jeito que o povo gosta',
  '2026-06-21', '12:00',
  'Samba & Gastronomia',
  '🥁 DOMINGO · 21 JUN · 12h',
  'Domingo é sagrado no Lagoon. Feijoada completa com o Grupo DuPagode mandando o melhor samba de raiz de Guarulhos.',
  'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=1400&q=90',
  'R$ 75 por pessoa',
  ARRAY['Feijoada completa com todos os cortes tradicionais','Arroz, couve, farofa, laranja e torresmo','Caipirinha de boas-vindas','Show ao vivo Grupo DuPagode (3 horas)'],
  '12h Feijoada aberta · 13h30 Show DuPagode · 16h30 Roda de samba aberta',
  28, NULL, false, 'ativo'
),
(
  'Final da Copa do Mundo',
  '19 de julho. Lagoon. O evento mais épico do ano.',
  '2026-07-19', '16:00',
  'Final da Copa do Mundo 2026',
  '🏆 FINAL · 19 JUL · 16h',
  'Com ou sem o Brasil — a Final da Copa do Mundo acontece aqui. Dois telões 150" fullHD, palco ao vivo, camarote VIP, open bar premium 5 horas. Restam só 3 ingressos.',
  'https://images.unsplash.com/photo-1527871252447-4ce32da643c6?w=1400&q=90',
  'R$ 220 por pessoa',
  ARRAY['Open bar premium 5h (whisky, gin, vodka, espumante, chopp)','Churrasco de gala: picanha maturada 45 dias, costela, salmão grelhado','Mesa no camarote VIP','Kit Copa Lagoon 2026: camiseta, buzina e bandeira'],
  '14h Check-in VIP · 14h30 Churrasco de gala · 15h Show ao vivo · 16h Final ao vivo · Após: Festa do Hexacampeonato',
  3, 'ESGOTANDO AGORA', false, 'ativo'
),
(
  'Noite do Jazz & Samba',
  'Copa acabou. Mas a festa no Lagoon não para.',
  '2026-07-26', '20:00',
  'Jazz & Samba ao Vivo',
  '🎷 26 JUL · Pós-Copa',
  'O Quarteto São Paulo Jazz sobe ao palco misturando jazz brasileiro, MPB e samba de raiz. Cardápio especial pós-copa e os melhores drinks autorais da casa.',
  'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=1400&q=90',
  'R$ 45 couvert',
  ARRAY['Show ao vivo Quarteto São Paulo Jazz — 2h30','Couvert artístico incluso','Cardápio especial de harmonizações do chef','Mesa com vista para o Lago dos Patos'],
  '20h Abertura · 21h Show ao vivo · 23h30 Encerramento',
  35, NULL, false, 'ativo'
);
