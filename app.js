/* Tutoriales
https://www.youtube.com/watch?v=EuZnr5NZWso

https://www.youtube.com/watch?v=pk5WNnTzYyw

https://www.youtube.com/watch?v=_8HdvDqMVUI

*/


const express = require ('express');
const app     = express();


app.use(express.static('public'));


app.listen(3000, () => {
  console.log('Servidor iniciado');

  const button = document.getElementById('myButton');
  button.addEventListener('click', function(e) {
    console.log('button was clicked');
  });

});
