$(document).ready(function() {

    // Make table of contents collapsable
    $('.toc p b a').on('click', function() {
        $(this).parent().parent().next('dl').slideToggle('fast', function() {
            $(this).parent().toggleClass('closed');
        });
        return false;
    });
    
    // Add anchor link to scroll to the top of the page
    $('body').append('<a href="#top" id="totop">^ <span>Use Elevator</span></a>');
    $('#totop').on('click', function() {
        $('html,body').animate({scrollTop: '0px'}, 1000);
        return false;
    });
    
    $('.toc p b').append('<a href="">Hide</a>');
    $('.section .toc').prepend('<p><b>Article navigation <a href="">Hide</a></b></p>');
   
    $('#marginalia ul ul a').prepend('<i class="fa fa-chevron-right"></i>');

});
