
/*
async function fetchnews(){
const apikey = "MnXHZmDbpMQ7LRRugEJLJ1mvVu9NZ8PDEUbqpr69";

try{
  for(let i = 1; i<=5; i++){
 const response = await fetch(`https://api.thenewsapi.com/v1/news/all?api_token=${apikey}&search=shark orca&page=${i}`);
 const data = await response.json();
 console.log(data);
}

}
catch(error){
  console.error("エラーが発生しました",error);
}
}

fetchnews();


async function fetchlocale(){

try{
 const response = await fetch("https://nominatim.openstreetmap.org/search?q=＆北海道&format=json&limit=1");
 const data = await response.json();
 console.log(data);
 console.log(data);

}
catch(error){
  console.error("エラーが発生しました",error);
}
}

fetchlocale();

async function fetchtext(){
  const res = await fetch("https://libretranslate.de/translate", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    q: "A great white shark was spotted near Cape Town.",
    source: "en",
    target: "ja",
    format: "text"
  })
});

const data = await res.json();
console.log(data.translatedText);
}


fetchtext();




async function fetchtranslate(){
  const text = "hello everyone"
  const fromlang = "en";
  const tolang = "ja";
const apikey = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${fromlang}|${tolang}`;

try{
 const response = await fetch(apikey); 
 const data = await response.json();
 console.log(data);

}
catch(error){
  console.error("エラーが発生しました",error);
}
}

fetchtranslate();


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

*/



