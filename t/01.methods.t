use Test::More tests => 29;

BEGIN {
use_ok( 'Getopt::Param' );
}

diag( "Testing Getopt::Param $Getopt::Param::VERSION methods" );

my @cst = qw(
    --alone
    --empty-equals=
    --equals-string=foo
    --multi=1
    --multi=2
    --multi=3
    invalid
);

push @cst, '--equals-phrase=foo bar baz'; # its called like this: --equals-phrase="foo bar baz"
    
my $par = Getopt::Param->new({
    'array_ref' => \@cst,
    'quiet'     => 1, # Gauranteed a 'Argument 6 did not match (?-xism:^--)'
});

my $inc;
{ 
    local @ARGV = @cst;
    $inc = Getopt::Param->new({ 'quiet' => 1 });
}

my %val = (
    'alone'         => '--alone',
    'empty-equals'  => '', 
    'equals-string' => 'foo',
    'equals-phrase' => 'foo bar baz',
);

my %tst = (
    '1' => ' - from array_ref key in new()',
    '2' => ' - from @ARGV',
);

my $prm = 1;

    my $scalar = $par->param('multi');
    ok($scalar eq '1', 'scalar context' . $tst{ $prm });

    my $array = join ',', sort $par->param('multi');
    ok($array eq '1,2,3', 'array context' . $tst{ $prm });

    my $keys = join ',', sort $par->param();

    ok($keys eq 'alone,empty-equals,equals-phrase,equals-string,multi', 'no args' . $tst{ $prm });
    
    $par->param('new', 1,2,3);
    my $new = join ',', sort $par->param('new');
    ok($new eq '1,2,3', 'new param' . $tst{ $prm });

    $par->param('new', 'n1', 'n2');
    my $edit = join ',', sort $par->param('new');
    ok($edit eq 'n1,n2', 'update param' . $tst{ $prm });
    
    $par->append_param('new', 'atend');
    my $apnd = join ',', $par->param('new');
    ok($apnd eq 'n1,n2,atend', 'append param' . $tst{ $prm });
    
    $par->prepend_param('new', 'atfront', 'front2');
    my $prpd = join ',', $par->param('new');
    ok($prpd eq 'atfront,front2,n1,n2,atend', 'prepend param' . $tst{ $prm });
    
    ok($par->exists_param('new') eq '1', 'does exist' . $tst{ $prm });
    
    ok(ref $par->delete_param('new') eq 'ARRAY', 'delete return' . $tst{ $prm });
    
    ok(!$par->exists_param('new'), 'does not exist' . $tst{ $prm });
    
    for my $key ( sort keys %val ){
        ok($par->param($key) eq $val{ $key }, "proper value: $key");
    }

{    
my $prm = 2;

    my $scalar = $inc->param('multi');
    ok($scalar eq '1', 'scalar context' . $tst{ $prm });

    my $array = join ',', sort $inc->param('multi');
    ok($array eq '1,2,3', 'array context' . $tst{ $prm });

    my $keys = join ',', sort $inc->param();
    ok($keys eq 'alone,empty-equals,equals-phrase,equals-string,multi', 'no args' . $tst{ $prm });

    $inc->param('new', 1,2,3);
    my $new = join ',', sort $inc->param('new');
    ok($new eq '1,2,3', 'new param' . $tst{ $prm });

    $inc->param('new', 'n1', 'n2');
    my $edit = join ',', sort $inc->param('new');
    ok($edit eq 'n1,n2', 'update param' . $tst{ $prm });

    $inc->append_param('new', 'atend');
    my $apnd = join ',', $inc->param('new');
    ok($apnd eq 'n1,n2,atend', 'append param' . $tst{ $prm });
    
    $inc->prepend_param('new', 'atfront', 'front2');
    my $prpd = join ',', $inc->param('new');
    ok($prpd eq 'atfront,front2,n1,n2,atend', 'prepend param' . $tst{ $prm });
    
    ok($inc->exists_param('new') eq '1', 'does exist' . $tst{ $prm });
    
    ok(ref $inc->delete_param('new') eq 'ARRAY', 'delete param' . $tst{ $prm });
    
    ok(!$inc->exists_param('new'), 'does not exist' . $tst{ $prm });
    
    for my $key ( sort keys %val ){
        ok($inc->param($key) eq $val{ $key }, "proper value: $key" . $tst{ $prm });
    }   
}