<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>残り時間</title>

  <style>
    body {
      font-family: sans-serif;
      padding: 30px;
      background: #f5f5f5;
    }

    h1 {
      color: #333;
    }

    .box {
      background: blue;
      padding: 20px;
      border-radius: 10px;
      max-width: 400px;
    }

    #result {
      margin-top: 20px;
      font-size: 20px;
    }

li {

  margin-bottom: 10px;
  border: 2px solid white;
  border-radius: 10px;
  padding: 10px;
  list-style: none;
  background: rgba(255,255,255,0.2);
  background: white;
color: blue;
  
  opacity: 0;
  transform: translateY(50px);

  transition:
    opacity 0.5s,
    transform 0.5s;
}
    
    li.show {
  opacity: 1;
  transform: translateY(0);
}
    
  </style>
</head>

<body>

  <div class="box">

   <h1>残り時間</h1>

<p id="todayTime"></p>

<p>寝る時間を選んでください</p>

<input type="time" id="sleepTime">

    <button onclick="showSuggestions()">
      残り時間で出来ること
    </button>

    <div id="result"></div>

  </div>

  <script>

    // 行動データ
    const actions = [
      { name: "アニメ1話", minutes: 24 },
      { name: "散歩", minutes: 30 },
      { name: "筋トレ", minutes: 15 },
      { name: "課題", minutes: 90 },
      { name: "読書", minutes: 20 },
      { name: "部会", minutes: 10 }
    ];

    // ボタンを押した時に動く
    function showSuggestions() {// 現在時刻取得
const now = new Date();

const nowHours = now.getHours();
const nowMinutes = now.getMinutes();

// 今を分に変換
const currentTotal =
  nowHours * 60 + nowMinutes;

// 24:00 は 1440分
const remainingToday =
  1440 - currentTotal;
      
const todayHours =
  Math.floor(remainingToday / 60);

const todayMinutes =
  remainingToday % 60;
      
      document.getElementById("todayTime")
  .innerText =
  `今日終了まで ${todayHours}時間${todayMinutes}分`;
      // 入力された時間を取得
      const sleepTime =
            document.getElementById("sleepTime").value;

      // 入力されてなかったら終了
      if (!sleepTime) {
        alert("寝る時間を選んでください");
        return;
      }

      // 入力時間を分解
      const parts = sleepTime.split(":");

      const sleepHours = Number(parts[0]);
      const sleepMinutes = Number(parts[1]);

      // 寝る時間を分に変換
      const sleepTotal =
        sleepHours * 60 + sleepMinutes;

      // 残り時間
      const remaining =
        sleepTotal - currentTotal;
      
　　　const remainingHours =
 　　　 Math.floor(remaining / 60);

　　　const remainingMinutes =
  　　　remaining % 60;
      
      let comment = "";

if (remaining <= 30) {

  comment =
    "あと三十分”も”ある";
   

} else if (remaining <= 90) {

  comment =
    "集中系タスクもできそうです";

} else {

  comment =
    "まとまった時間があります";
}
      
      // 表示用HTML
　　　let html = `
 　　
    <p>
 　 残り ${remainingHours}時間 ${remainingMinutes}分
　　</p>

  <p>
   今日終了まで
   ${todayHours}時間
   ${todayMinutes}分
  </p>

<p>${comment}</p>

      <h3></h3>
       <ul>
   `;
      // 行動をチェック
      actions.forEach(action => {

        // できるものだけ表示
        if (action.minutes <= remaining) {

          html += `
            <li>
              ${action.name}
              (${action.minutes}分)
            </li>
          `;
        }

      });

      html += "</ul>";

      // 画面に表示
      document.getElementById("result").innerHTML = html;
      const items =
  document.querySelectorAll("li");

const observer =
  new IntersectionObserver(entries => {

    entries.forEach(entry => {

   if (entry.isIntersecting) {

  entry.target.classList.add("show");

} else {

  entry.target.classList.remove("show");

}

    });

  });

items.forEach(item => {
  observer.observe(item);
});
    }

  </script>

</body>
</html>

