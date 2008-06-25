use Test::More tests => 41;

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

{
    my $hlp_cnt = 0;
    my $prm = Getopt::Param->new({'no_args_help' => 1, 'help_coderef' => sub {$hlp_cnt++; }, 'array_ref' => [] });
    ok($hlp_cnt == 1, 'no args triggers help when no_args_help is true');
    $prm->help();
    ok($hlp_cnt == 2, 'help method');
    
    my $par = Getopt::Param->new({'array_ref' => [qw(--before -- --after)]});
    ok($par->exists_param('before') eq '1', 'before --');
    ok(!$par->exists_param('after'), 'after --');
    
    my $only = Getopt::Param->new({'array_ref' => ['--bar'], 'help_coderef' => sub {$hlp_cnt++; }, 'known_only' => ['foo'] });
    ok($hlp_cnt == 3, 'known only constraint bad (see warning output)');

    my $only_b = Getopt::Param->new({'array_ref' => ['--foo'], 'help_coderef' => sub {$hlp_cnt++; }, 'known_only' => ['foo'] });
    ok($hlp_cnt == 3, 'known only constraint ok');
    
    my $req = Getopt::Param->new({'array_ref' => ['--bar'], 'help_coderef' => sub {$hlp_cnt++; }, 'required' => ['foo'] });
    ok($hlp_cnt == 4, 'required constraint (see warning output)');

    my $req_b = Getopt::Param->new({'array_ref' => ['--foo'], 'help_coderef' => sub {$hlp_cnt++; }, 'required' => ['foo'] });
    ok($hlp_cnt == 4, 'required constraint ok');

    my $val = Getopt::Param->new({'array_ref' => ['--fail'], 'help_coderef' => sub {$hlp_cnt++; }, 'validate' => sub {my ($prm)=@_;if ($prm->get_param('fail')) {$hlp_cnt++;return;}return 1;} });
# we do 6 instead of 5 since validate and help are incrementing it...
    ok($hlp_cnt == 6, 'validate constraint fail');
    
    my $val_b = Getopt::Param->new({'array_ref' => ['--foo'], 'validate' => sub {my ($prm)=@_;if ($prm->get_param('fail')) {$hlp_cnt++;return;}return 1;} });
    ok($hlp_cnt == 6, 'validate constraint ok');

    my $act = Getopt::Param->new({'array_ref' => ['--usage'], 'help_coderef' => sub {$hlp_cnt++; }, 'actions' => ['usage', 1] });
    ok($hlp_cnt == 7, 'actions defauklt to help');

    my $act_b = Getopt::Param->new({'array_ref' => ['--usage'], 'help_coderef' => sub {$hlp_cnt++; }, 'actions' => ['usage', sub { $hlp_cnt += 2 }] });
    ok($hlp_cnt == 9, 'actions defauklt to help');

}