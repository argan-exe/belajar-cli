<!doctype html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>CLI Dojo Lanjutan</title>
  <link href="https://fonts.googleapis.com/css2?family=Fira+Sans:wght@400;500;600;700;800&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
  <style>
    :root{--bg:#101915;--panel:#19251f;--line:#33483b;--lime:#b9f57b;--cream:#f0f4e8;--muted:#a8b7a9;--red:#ff9d8c}
    *{box-sizing:border-box}
    body{margin:0;background:var(--bg);color:var(--cream);font-family:'Fira Sans',sans-serif}
    .mono{font-family:'Space Mono',monospace}
    .page-surface{background:radial-gradient(ellipse at 85% 0%,#29422b 0%,transparent 45%),#101915}
    .shell{background:var(--panel);border:1px solid var(--line);box-shadow:0 24px 70px #0005}
    .answer{background:#202e26;border:1px solid #435747;transition:border-color .2s,background .2s,transform .2s}
    .answer:hover:not(:disabled){background:#2a3d2d;border-color:var(--lime);transform:translateY(-2px)}
    .answer.correct{border-color:var(--lime);background:#29452c}
    .answer.wrong{border-color:var(--red);background:#492c29}
    input{background:#101b15;border:1px solid #49604d;color:var(--cream);outline:none}
    input:focus{border-color:var(--lime);box-shadow:0 0 0 3px #b9f57b25}
    button:focus-visible,input:focus-visible{outline:3px solid var(--lime);outline-offset:3px}
    .primary{background:var(--lime);color:#122018;transition:filter .2s,transform .2s}
    .primary:hover:not(:disabled){filter:brightness(1.1);transform:translateY(-2px)}
    button:disabled{opacity:.65;cursor:default}
    .fade-in{animation:rise .42s ease both}
    @keyframes rise{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
    @media(prefers-reduced-motion:reduce){.fade-in{animation:none}.primary,.answer{transition:none}}
  </style>
  <script src="https://cdn.tailwindcss.com/3.4.17"></script>
</head>
<body class="w-full">
<div class="page-surface w-full min-h-screen">
  <header class="w-full border-b border-[#34483a]">
    <div class="max-w-5xl mx-auto px-5 sm:px-8 py-5 flex items-center justify-between gap-4">
      <div class="flex items-center gap-3">
        <span aria-hidden="true" class="mono grid place-items-center w-10 h-10 rounded-lg border border-[#b9f57b] text-[#b9f57b] font-bold">&gt;_</span>
        <span class="mono font-bold tracking-tight">CLI / DOJO</span>
      </div>
      <span class="mono text-xs border border-[#47663b] rounded-full px-3 py-1">ASJ · CLI LANJUTAN</span>
    </div>
  </header>

  <main class="w-full max-w-5xl mx-auto px-5 sm:px-8 pt-10 pb-16">
    <div class="max-w-2xl mb-8 fade-in">
      <p class="mono text-sm uppercase tracking-widest mb-3 text-[#b9f57b]">LEVEL 6 &amp; 7</p>
      <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight leading-tight mb-3">Naik satu tingkat lagi.</h1>
      <p class="leading-relaxed text-[#c4d1c0]">Dua level lanjutan: kelola layanan dan jaringan, lalu biasakan kebiasaan admin yang rapi dan aman. Salah? Tenang, ada pembahasannya.</p>
    </div>

    <section id="entry-view" class="shell rounded-2xl p-6 sm:p-9 max-w-2xl fade-in">
      <h2 class="text-2xl font-bold mb-2">Siap lanjut?</h2>
      <p class="mb-7 leading-relaxed text-[#c4d1c0]">Isi nama dan kelasmu untuk memulai. Setelah selesai, hasil latihan bisa diunduh sebagai CSV.</p>
      <form id="entry-form" class="space-y-5">
        <div>
          <label for="student-name" class="block mb-2 font-semibold">Nama lengkap</label>
          <input id="student-name" class="w-full rounded-lg px-4 py-3" placeholder="Contoh: Budi Santoso" maxlength="80" autocomplete="name" required>
        </div>
        <div>
          <label for="student-class" class="block mb-2 font-semibold">Kelas</label>
          <input id="student-class" class="w-full rounded-lg px-4 py-3" placeholder="Contoh: XI TKJ 1" maxlength="50" required>
        </div>
        <p class="leading-relaxed text-[#a8b7a9]"><span id="total-info"></span> Tiap perintah bernilai 2 poin: 1 untuk paham fungsi, 1 untuk mengetik sintaksnya.</p>
        <button type="submit" class="primary rounded-lg px-6 py-3 font-bold">Mulai latihan →</button>
      </form>
    </section>

    <section id="quiz-view" class="hidden max-w-3xl" aria-label="Soal kuis">
      <div class="flex flex-wrap justify-between items-end gap-4 mb-5">
        <div>
          <p id="level-label" class="mono text-[#b9f57b] mb-1"></p>
          <h2 id="command-title" class="mono font-bold text-2xl sm:text-3xl"></h2>
        </div>
        <div class="text-right">
          <p id="question-count" class="mono text-[#a8b7a9]"></p>
          <p id="live-score" class="font-semibold"></p>
        </div>
      </div>
      <div id="progress" class="h-2 rounded-full bg-[#344338] mb-6 overflow-hidden" role="progressbar" aria-label="Kemajuan kuis" aria-valuemin="0" aria-valuemax="16" aria-valuenow="0">
        <div id="progress-fill" class="h-full bg-[#b9f57b] transition-all duration-300" style="width:0%"></div>
      </div>
      <article class="shell rounded-2xl p-6 sm:p-9 fade-in">
        <div id="layer-one">
          <p class="mono text-sm text-[#b9f57b] mb-3">01 / PAHAMI FUNGSINYA</p>
          <h3 class="text-xl font-bold mb-6">Buat apa perintah ini?</h3>
          <div id="options" class="grid gap-3"></div>
        </div>
        <div id="layer-two" class="hidden">
          <p class="mono text-sm text-[#b9f57b] mb-3">02 / COBA KETIK</p>
          <h3 class="text-xl font-bold mb-2">Gimana cara pakainya?</h3>
          <p id="mission-text" class="text-[#c4d1c0] mb-5 leading-relaxed"></p>
          <form id="command-form">
            <label for="command-answer" class="block mb-2 font-semibold">Ketik perintah untuk misi berikut:</label>
            <input id="command-answer" class="mono w-full rounded-lg px-4 py-3 mb-4" placeholder="Ketik perintah di sini..." autocomplete="off" autocapitalize="off" spellcheck="false" required>
            <button id="check-button" type="submit" class="primary rounded-lg px-5 py-3 font-bold">Periksa jawaban</button>
          </form>
        </div>
        <div id="feedback" role="status" aria-live="polite" class="hidden mt-6 border-t border-[#435747] pt-5">
          <p id="feedback-title" class="font-bold mb-2"></p>
          <p id="feedback-detail" class="text-[#c3d0c1] leading-relaxed mb-5"></p>
          <button id="next-button" type="button" class="primary rounded-lg px-5 py-3 font-bold"></button>
        </div>
      </article>
    </section>

    <section id="result-view" class="shell hidden max-w-2xl rounded-2xl p-6 sm:p-9 fade-in">
      <p class="mono text-sm text-[#b9f57b] mb-3">LATIHAN SELESAI</p>
      <h2 class="text-2xl font-bold mb-3">Ini hasil latihanmu.</h2>
      <p id="result-identity" class="text-[#a8b7a9] mb-7"></p>
      <div class="grid sm:grid-cols-3 gap-3 mb-6">
        <div class="rounded-xl bg-[#25352a] p-5">
          <p class="mb-2 text-sm">Paham fungsi</p>
          <p id="result-layer1" class="mono font-bold text-2xl"></p>
        </div>
        <div class="rounded-xl bg-[#25352a] p-5">
          <p class="mb-2 text-sm">Praktik mengetik</p>
          <p id="result-layer2" class="mono font-bold text-2xl"></p>
        </div>
        <div class="rounded-xl bg-[#324b2d] p-5">
          <p class="mb-2 text-sm">Total poin</p>
          <p id="result-total" class="mono font-bold text-2xl text-[#b9f57b]"></p>
        </div>
      </div>
      <p class="leading-relaxed mb-5 text-[#c4d1c0]">Unduh hasil dan detail jawabanmu sebagai file CSV.</p>
      <button id="download-button" type="button" class="primary rounded-lg px-5 py-3 font-bold">Unduh hasil CSV</button>
    </section>

    <footer class="max-w-3xl mt-10 border-t border-[#34483a] pt-5">
      <p class="leading-relaxed text-sm text-[#a8b7a9]">Ini latihan sintaks, bukan terminal Linux sungguhan. Di terminal asli, pakai --help atau man untuk mencari bantuan; Tab membantu melengkapi ketikan dan panah atas mengulang perintah.</p>
    </footer>
  </main>
</div>

<script>
  const questions = [
    {level:6,cmd:'systemctl stop',purpose:'Menghentikan layanan yang sedang berjalan',options:['Menghentikan layanan yang sedang berjalan','Menghapus layanan dari komputer','Mematikan komputer'],mission:'Hentikan layanan apache2 sebagai root.',accepted:['systemctl stop apache2','systemctl stop apache2.service'],example:'systemctl stop apache2',explanation:'Pasangannya adalah start. stop hanya mematikan layanan sampai komputer di-restart, kecuali kamu juga menjalankan disable.'},
    {level:6,cmd:'apt remove',purpose:'Menghapus paket aplikasi yang sudah terpasang',options:['Menghapus daftar paket dari repositori','Menghapus paket aplikasi yang sudah terpasang','Menghapus file di folder aktif'],mission:'Hapus paket apache2 sebagai root.',accepted:['apt remove apache2','apt remove -y apache2','apt remove apache2 -y','apt purge apache2'],example:'apt remove apache2',explanation:'remove membuang aplikasinya tetapi file konfigurasi tetap tersimpan. apt purge membuang konfigurasinya juga.'},
    {level:6,cmd:'apt upgrade',purpose:'Memperbarui semua paket terpasang ke versi terbaru',options:['Memperbarui daftar paket dari repositori','Memperbarui semua paket terpasang ke versi terbaru','Memasang versi lama sebuah paket'],mission:'Perbarui semua paket yang terpasang sebagai root (anggap apt update sudah dijalankan).',accepted:['apt upgrade','apt upgrade -y','apt -y upgrade'],example:'apt upgrade',explanation:'Urutan yang benar: apt update dulu (ambil daftar terbaru), baru apt upgrade (pasang versi terbarunya).'},
    {level:6,cmd:'cat /etc/resolv.conf',purpose:'Melihat DNS server yang dipakai komputer',options:['Melihat DNS server yang dipakai komputer','Melihat daftar website yang pernah dibuka','Mengganti alamat IP komputer'],mission:'Tampilkan isi file /etc/resolv.conf.',accepted:['cat /etc/resolv.conf'],example:'cat /etc/resolv.conf',explanation:'Baris nameserver berisi alamat DNS server. Kalau nslookup gagal, file ini salah satu tempat pertama yang dicek.'},
    {level:6,cmd:'hostname -I',purpose:'Menampilkan alamat IP komputer saja, tanpa info lain',options:['Mengganti nama komputer','Menampilkan alamat IP komputer saja, tanpa info lain','Menampilkan gateway default'],mission:'Tampilkan alamat IP komputermu dengan keluaran singkat (huruf I besar).',accepted:['hostname -I'],example:'hostname -I',explanation:'Lebih ringkas dari ip a. Perhatikan huruf besar I. Perintah hostname saja menampilkan nama komputer.'},
    {level:6,cmd:'traceroute',purpose:'Melacak jalur router yang dilewati menuju tujuan',options:['Menguji apakah tujuan merespons','Melacak jalur router yang dilewati menuju tujuan','Melihat tabel routing komputermu'],mission:'Lacak jalur menuju 8.8.8.8.',accepted:['traceroute 8.8.8.8','tracepath 8.8.8.8'],example:'traceroute 8.8.8.8',explanation:'Tiap baris adalah satu router (hop). Kalau perintahnya belum ada, pasang paket traceroute. Alternatif bawaan: tracepath.'},
    {level:6,cmd:'ss -tulpn | grep',purpose:'Memeriksa apakah port tertentu sedang dipakai layanan',options:['Membuka port tertentu di firewall','Memeriksa apakah port tertentu sedang dipakai layanan','Menguji kecepatan port'],mission:'Tampilkan port listening, tapi hanya baris yang mengandung :80 (gabungkan dengan pipe).',accepted:['ss -tulpn | grep :80'],regex:[/^ss -(?=[a-z]*t)(?=[a-z]*u)(?=[a-z]*l)(?=[a-z]*p)(?=[a-z]*n)[a-z]{5} ?\| ?grep :80$/],example:'ss -tulpn | grep :80',explanation:'Gabungan dua perintah yang sudah kamu kenal. Kalau barisnya muncul, web server memang sedang mendengarkan di port 80.'},
    {level:6,cmd:'nano /etc/network/interfaces',purpose:'Membuka file konfigurasi IP statis (pada Debian)',options:['Membuka file konfigurasi IP statis (pada Debian)','Menampilkan alamat IP saat ini','Menguji koneksi ke gateway'],mission:'Buka file /etc/network/interfaces untuk diedit.',accepted:['nano /etc/network/interfaces'],example:'nano /etc/network/interfaces',explanation:'Di sini address, netmask, dan gateway ditulis. Setelah disimpan, restart layanan jaringan agar berlaku.'},
    {level:7,cmd:'sudo',purpose:'Menjalankan satu perintah dengan hak akses root tanpa pindah akun',options:['Berpindah ke akun root sampai logout','Menjalankan satu perintah dengan hak akses root tanpa pindah akun','Menghapus akun pengguna'],mission:'Perbarui daftar paket dari akun biasa memakai hak root.',accepted:['sudo apt update'],example:'sudo apt update',explanation:'sudo hanya meminjam hak root untuk satu perintah. Lebih aman daripada su - karena tidak terus-menerus berada di akun root.'},
    {level:7,cmd:'history',purpose:'Menampilkan riwayat perintah yang pernah diketik',options:['Menampilkan riwayat perintah yang pernah diketik','Menampilkan log layanan','Menampilkan daftar file yang pernah dihapus'],mission:'Tampilkan riwayat perintahmu.',accepted:['history'],example:'history',explanation:'Cocok untuk mengulang perintah panjang. Ketik !nomor untuk menjalankan ulang baris tertentu.'},
    {level:7,cmd:'head -n',purpose:'Menampilkan beberapa baris pertama sebuah file',options:['Menampilkan beberapa baris terakhir sebuah file','Menampilkan beberapa baris pertama sebuah file','Menghitung jumlah baris sebuah file'],mission:'Tampilkan 5 baris pertama file /etc/passwd.',accepted:['head -n 5 /etc/passwd','head -n5 /etc/passwd','head -5 /etc/passwd'],example:'head -n 5 /etc/passwd',explanation:'head untuk bagian awal, tail untuk bagian akhir. Tanpa -n, hasil bawaannya 10 baris.'},
    {level:7,cmd:'wc -l',purpose:'Menghitung jumlah baris',options:['Menghitung jumlah baris','Menampilkan ukuran file dalam byte','Mencari baris tertentu'],mission:'Hitung jumlah baris di file /etc/passwd.',accepted:['wc -l /etc/passwd'],example:'wc -l /etc/passwd',explanation:'wc = word count, -l = lines. Sering dipasang setelah pipe, misalnya ls /etc | wc -l untuk menghitung isi folder.'},
    {level:7,cmd:'grep -i',purpose:'Mencari kata tanpa membedakan huruf besar dan kecil',options:['Mencari kata dan menampilkan nomor barisnya','Mencari kata tanpa membedakan huruf besar dan kecil','Mencari kata di semua folder'],mission:'Cari kata ROOT (huruf besar kecil tidak penting) di file /etc/passwd.',accepted:['grep -i root /etc/passwd'],example:'grep -i root /etc/passwd',explanation:'Tanpa -i, grep membedakan Root, root, dan ROOT. Opsi -i (ignore case) membuatnya dianggap sama.'},
    {level:7,cmd:'free -h',purpose:'Menampilkan penggunaan memori RAM dengan satuan mudah dibaca',options:['Menampilkan sisa ruang disk','Menampilkan penggunaan memori RAM dengan satuan mudah dibaca','Membebaskan memori yang terpakai'],mission:'Cek penggunaan RAM dengan satuan yang mudah dibaca.',accepted:['free -h'],example:'free -h',explanation:'free untuk RAM, df -h untuk disk. Server yang lambat biasanya salah satunya sudah penuh.'},
    {level:7,cmd:'ps aux | grep',purpose:'Memeriksa apakah sebuah program sedang berjalan sebagai proses',options:['Memeriksa apakah sebuah program sedang berjalan sebagai proses','Menghentikan sebuah program','Memasang program baru'],mission:'Tampilkan proses yang mengandung kata apache2 (gabungkan dengan pipe).',accepted:['ps aux | grep apache2'],regex:[/^ps aux ?\| ?grep apache2$/],example:'ps aux | grep apache2',explanation:'ps aux menampilkan semua proses, grep menyaringnya. Satu baris hasil biasanya adalah perintah grep itu sendiri, abaikan saja.'},
    {level:7,cmd:'ufw allow',purpose:'Mengizinkan lalu lintas ke port tertentu lewat firewall',options:['Membuka halaman web di port tertentu','Mengizinkan lalu lintas ke port tertentu lewat firewall','Menguji apakah port terbuka'],mission:'Izinkan koneksi ke port 22 (SSH) lewat firewall ufw sebagai root.',accepted:['ufw allow 22','ufw allow 22/tcp','ufw allow ssh'],example:'ufw allow 22',explanation:'Firewall yang aktif tapi belum mengizinkan port 22 bisa membuatmu terkunci dari server saat SSH. Izinkan dulu, baru aktifkan ufw.'}
  ];

  const $ = id => document.getElementById(id);
  const normalize = value => String(value).trim().replace(/\s+/g,' ').toLowerCase();
  // Kosongkan string ini kalau hasil tidak mau dikirim otomatis ke Google Sheets.
  const SHEETS_WEB_APP_URL = 'https://script.google.com/macros/s/AKfycbxH8XQajrQvrev6hs_yimIvCK5nrA-2x2sswlS9IkR18Nkp5FNpCc1lQXeCQ_9JMPXm/exec';
  const TOTAL_LEVELS = Math.max(...questions.map(x => x.level));
  $('total-info').textContent = questions.length + ' perintah · ' + (questions.length * 2) + ' poin maksimum.';
  $('progress').setAttribute('aria-valuemax', String(questions.length));
  let index = 0, layer1 = 0, layer2 = 0, student = null, details = [];

  function updateScore() {
    $('live-score').textContent = 'Fungsi ' + layer1 + ' · Praktik ' + layer2;
  }

  function showQuestion() {
    const q = questions[index];
    $('level-label').textContent = 'LEVEL ' + q.level + ' / ' + TOTAL_LEVELS;
    $('command-title').textContent = '$ ' + q.cmd;
    $('question-count').textContent = 'PERINTAH ' + (index + 1) + ' / ' + questions.length;
    updateScore();
    $('progress').setAttribute('aria-valuenow', String(index));
    $('progress-fill').style.width = (index / questions.length * 100) + '%';
    $('layer-one').classList.remove('hidden');
    $('layer-two').classList.add('hidden');
    $('feedback').classList.add('hidden');
    $('command-answer').value = '';

    const options = $('options');
    options.replaceChildren();
    [...q.options].sort(() => Math.random() - 0.5).forEach(option => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'answer text-left rounded-lg p-4 w-full font-medium';
      button.textContent = option;
      button.addEventListener('click', () => {
        const correct = option === q.purpose;
        if (correct) layer1++;
        details[index] = {perintah:q.cmd,level:q.level,jawaban_fungsi:option,benar_fungsi:correct};
        options.querySelectorAll('button').forEach(b => {
          b.disabled = true;
          if (b.textContent === q.purpose) b.classList.add('correct');
          else if (b === button) b.classList.add('wrong');
        });
        $('feedback-title').textContent = correct ? 'Betul!' : 'Belum tepat.';
        $('feedback-detail').textContent = 'Jawaban benar: ' + q.purpose + '.';
        $('next-button').textContent = 'Lanjut ke praktik →';
        $('feedback').classList.remove('hidden');
        updateScore();
      });
      options.appendChild(button);
    });
  }

  $('entry-form').addEventListener('submit', event => {
    event.preventDefault();
    student = {nama:$('student-name').value.trim(), kelas:$('student-class').value.trim()};
    if (!student.nama || !student.kelas) return;
    $('entry-view').classList.add('hidden');
    $('quiz-view').classList.remove('hidden');
    showQuestion();
  });

  $('command-form').addEventListener('submit', event => {
    event.preventDefault();
    const q = questions[index], raw = $('command-answer').value;
    const typed = normalize(raw);
    const correct = q.accepted.some(answer => normalize(answer) === typed) || (q.regex || []).some(re => re.test(typed));
    if (correct) layer2++;
    Object.assign(details[index], {jawaban_praktik:raw,benar_praktik:correct});
    $('command-answer').disabled = true;
    $('check-button').disabled = true;
    $('feedback-title').textContent = correct ? 'Sintaks benar!' : 'Sintaks belum tepat.';
    $('feedback-detail').textContent = 'Contoh jawaban: ' + q.example + '. ' + q.explanation;
    $('next-button').textContent = index === questions.length - 1 ? 'Lihat nilai →' : 'Perintah berikutnya →';
    $('feedback').classList.remove('hidden');
    updateScore();
  });

  $('next-button').addEventListener('click', () => {
    if (!$('layer-one').classList.contains('hidden')) {
      $('layer-one').classList.add('hidden');
      $('layer-two').classList.remove('hidden');
      $('feedback').classList.add('hidden');
      $('mission-text').textContent = questions[index].mission;
      $('command-answer').disabled = false;
      $('check-button').disabled = false;
      $('command-answer').focus();
    } else if (++index < questions.length) {
      showQuestion();
    } else {
      finish();
    }
  });

  function finish() {
    $('quiz-view').classList.add('hidden');
    $('result-view').classList.remove('hidden');
    $('result-identity').textContent = student.nama + ' · ' + student.kelas;
    $('result-layer1').textContent = layer1 + ' / ' + questions.length;
    $('result-layer2').textContent = layer2 + ' / ' + questions.length;
    $('result-total').textContent = (layer1 + layer2) + ' / ' + (questions.length * 2);
    $('progress').setAttribute('aria-valuenow', String(questions.length));
    $('progress-fill').style.width = '100%';
    if (!SHEETS_WEB_APP_URL) return;
    const submission = {
      nama: student.nama,
      kelas: student.kelas,
      skor_fungsi: layer1,
      skor_praktik: layer2,
      skor_total: layer1 + layer2,
      detail_jawaban: JSON.stringify(details)
    };
    fetch(SHEETS_WEB_APP_URL, {
      method: 'POST',
      mode: 'no-cors',
      headers: {'Content-Type': 'text/plain;charset=utf-8'},
      body: JSON.stringify(submission),
      keepalive: true
    }).catch(() => {});
  }

  $('download-button').addEventListener('click', () => {
    const quote = value => '"' + String(value ?? '').replace(/"/g,'""') + '"';
    const rows = [
      ['nama','kelas','skor_fungsi','skor_praktik','skor_total','detail_jawaban'],
      [student.nama,student.kelas,layer1,layer2,layer1 + layer2,JSON.stringify(details)]
    ];
    const csv = '\uFEFF' + rows.map(row => row.map(quote).join(',')).join('\r\n');
    const url = URL.createObjectURL(new Blob([csv], {type:'text/csv;charset=utf-8'}));
    const link = document.createElement('a');
    link.href = url;
    link.download = 'cli-dojo-lanjutan-hasil.csv';
    document.body.appendChild(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 60000);
  });
</script>
</body>
</html>
