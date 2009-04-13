
document.observe('dom:loaded', function(){  
  if($('main').getHeight() < $('sidebar').getHeight()) {
    $('main_wrapper').setStyle({paddingBottom:$('sidebar').getHeight() - $('main').getHeight() + 'px'});
  }
})
