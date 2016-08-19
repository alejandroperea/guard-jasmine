require 'guard/compat/test/helper'
require 'guard/jasmine'

RSpec.describe Guard::Jasmine do
  let(:guard) { Guard::Jasmine.new }

  let(:runner) { Guard::Jasmine::Runner }
  let(:inspector) { Guard::Jasmine::Inspector }
  let(:formatter) { Guard::Jasmine::Formatter }
  let(:server) { Guard::Jasmine::Server }

  let(:defaults) { Guard::Jasmine::DEFAULT_OPTIONS }

  let(:ui) { Guard::Compat::UI }

  before do
    allow(ui).to receive(:info)
    allow(ui).to receive(:debug)
    allow(ui).to receive(:error)
    allow(ui).to receive(:warning)
    allow(ui).to receive(:color_enabled?).and_return(true)

    allow(inspector).to receive(:clean) { |specs, _options| specs }
    allow(guard.runner).to receive(:run).and_return({})
    allow(formatter).to receive(:notify)
    allow(server).to receive(:start)
    allow(server).to receive(:stop)
    allow(server).to receive(:detect_server)
    allow(Guard::Jasmine).to receive(:which).and_return '/usr/local/bin/phantomjs'
  end

  describe '#initialize' do
    context 'when no options are provided' do
      it 'sets a default :server_env option' do
        expect(guard.options[:server_env]).to eql defaults[:server_env]
      end

      it 'sets a default :server_timeout option' do
        expect(guard.options[:server_timeout]).to eql 60
      end

      it 'otherwise the default should be /jasmine' do
        expect(guard.options[:server_mount]).to eql defaults[:server_mount]
      end

      it 'finds a free port for the :port option' do
        expect(Guard::Jasmine).to receive(:find_free_server_port).and_return 9999
        guard = Guard::Jasmine.new
        expect(guard.options[:port]).to eql 9999
      end

      it 'sets a default :rackup_config option' do
        expect(guard.options[:rackup_config]).to eql nil
      end

      it 'sets a default :timeout option' do
        expect(guard.options[:timeout]).to eql 60
      end

      it 'sets a default :all_on_start option' do
        expect(guard.options[:all_on_start]).to eql true
      end

      it 'sets a default :notifications option' do
        expect(guard.options[:notification]).to eql true
      end

      it 'sets a default :hide_success option' do
        expect(guard.options[:hide_success]).to eql false
      end

      it 'sets a default :max_error_notify option' do
        expect(guard.options[:max_error_notify]).to eql 3
      end

      it 'sets a default :keep_failed option' do
        expect(guard.options[:keep_failed]).to eql true
      end

      it 'sets a default :all_after_pass option' do
        expect(guard.options[:all_after_pass]).to eql true
      end

      it 'sets a default :specdoc option' do
        expect(guard.options[:specdoc]).to eql :failure
      end

      it 'sets a default :console option' do
        expect(guard.options[:console]).to eql :failure
      end

      it 'sets a default :errors option' do
        expect(guard.options[:errors]).to eql :failure
      end

      it 'sets a default :focus option' do
        expect(guard.options[:focus]).to eql true
      end

      it 'sets a default :clean option' do
        expect(guard.options[:clean]).to eql true
      end

      it 'sets a default :coverage option' do
        expect(guard.options[:coverage]).to eql false
      end

      it 'sets a default :coverage_html option' do
        expect(guard.options[:coverage_html]).to eql false
      end

      it 'sets a default :coverage_summary option' do
        expect(guard.options[:coverage_summary]).to eql false
      end

      it 'sets a :statements_threshold option' do
        expect(guard.options[:statements_threshold]).to eql 0
      end

      it 'sets a :functions_threshold option' do
        expect(guard.options[:functions_threshold]).to eql 0
      end

      it 'sets a :branches_threshold option' do
        expect(guard.options[:branches_threshold]).to eql 0
      end

      it 'sets a :lines_threshold option' do
        expect(guard.options[:lines_threshold]).to eql 0
      end

      it 'sets last run failed to false' do
        expect(guard.last_run_failed).to eql false
      end

      it 'sets last failed paths to empty' do
        expect(guard.last_failed_paths).to be_empty
      end

      it 'tries to auto detect the :phantomjs_bin' do
        allow(::Guard::Jasmine).to receive(:which).and_return '/bin/phantomjs'
        expect(::Guard::Jasmine.new.options[:phantomjs_bin]).to eql '/bin/phantomjs'
      end

      context 'with a spec/javascripts folder' do
        before do
          allow(File).to receive(:exist?).with('spec/javascripts').and_return true
        end

        it 'sets a default :spec_dir option' do
          expect(::Guard::Jasmine.new.options[:spec_dir]).to eql 'spec/javascripts'
        end

        it 'detects the current server' do
          expect(server).to receive(:detect_server).with('spec/javascripts')
          ::Guard::Jasmine.new
        end
      end

      context 'without a spec/javascripts folder' do
        before do
          allow(File).to receive(:exist?).with('spec/javascripts').and_return false
        end

        it 'sets a default :spec_dir option' do
          expect(::Guard::Jasmine.new.options[:spec_dir]).to eql 'spec'
        end

        it 'detects the current server' do
          expect(server).to receive(:detect_server).with('spec')
          ::Guard::Jasmine.new
        end
      end
    end

    context 'with other options than the default ones' do
      let(:guard) do
        Guard::Jasmine.new(
          server:               :jasmine_gem,
          server_env:           'test',
          server_timeout:       20,
          server_mount:         '/foo',
          port:                 4321,
          rackup_config:        'spec/dummy/config.ru',
          jasmine_url:          'http://192.168.1.5/jasmine',
          phantomjs_bin:        '~/bin/phantomjs',
          timeout:              20_000,
          spec_dir:             'spec',
          all_on_start:         false,
          notification:         false,
          max_error_notify:     5,
          hide_success:         true,
          keep_failed:          false,
          all_after_pass:       false,
          specdoc:              :always,
          focus:                false,
          clean:                false,
          errors:               :always,
          console:              :always,
          coverage:             true,
          coverage_html:        true,
          coverage_summary:     true,
          statements_threshold: 95,
          functions_threshold:  90,
          branches_threshold:   85,
          lines_threshold:      80
        )
      end

      it 'sets the :server option' do
        expect(guard.options[:server]).to eql :jasmine_gem
      end

      it 'sets the :server_env option' do
        expect(guard.options[:server_env]).to eql 'test'
      end

      it 'sets the :server_timeout option' do
        expect(guard.options[:server_timeout]).to eql 20
      end

      it 'sets the :server_mount option' do
        expect(guard.options[:server_mount]).to eq '/foo'
      end

      it 'sets the :port option' do
        expect(guard.options[:port]).to eql 4321
      end

      it 'sets a default :rackup_config option' do
        expect(guard.options[:rackup_config]).to eql 'spec/dummy/config.ru'
      end

      it 'sets the :phantomjs_bin option' do
        expect(guard.options[:phantomjs_bin]).to eql '~/bin/phantomjs'
      end

      it 'sets the :phantomjs_bin option' do
        expect(guard.options[:timeout]).to eql 20_000
      end

      it 'sets the :spec_dir option' do
        expect(guard.options[:spec_dir]).to eql 'spec'
      end

      it 'sets the :all_on_start option' do
        expect(guard.options[:all_on_start]).to eql false
      end

      it 'sets the :notifications option' do
        expect(guard.options[:notification]).to eql false
      end

      it 'sets the :hide_success option' do
        expect(guard.options[:hide_success]).to eql true
      end

      it 'sets the :max_error_notify option' do
        expect(guard.options[:max_error_notify]).to eql 5
      end

      it 'sets the :keep_failed option' do
        expect(guard.options[:keep_failed]).to eql false
      end

      it 'sets the :all_after_pass option' do
        expect(guard.options[:all_after_pass]).to eql false
      end

      it 'sets the :specdoc option' do
        expect(guard.options[:specdoc]).to eql :always
      end

      it 'sets the :console option' do
        expect(guard.options[:console]).to eql :always
      end

      it 'sets the :errors option' do
        expect(guard.options[:errors]).to eql :always
      end

      it 'sets the :focus option' do
        expect(guard.options[:focus]).to eql false
      end

      it 'sets the :clean option' do
        expect(guard.options[:clean]).to eql false
      end

      it 'sets a :coverage option' do
        expect(guard.options[:coverage]).to eql true
      end

      it 'sets a default :coverage_html option' do
        expect(guard.options[:coverage_html]).to eql true
      end

      it 'sets a default :coverage_summary option' do
        expect(guard.options[:coverage_summary]).to eql true
      end

      it 'sets a :statements_threshold option' do
        expect(guard.options[:statements_threshold]).to eql 95
      end

      it 'sets a :functions_threshold option' do
        expect(guard.options[:functions_threshold]).to eql 90
      end

      it 'sets a :branches_threshold option' do
        expect(guard.options[:branches_threshold]).to eql 85
      end

      it 'sets a :lines_threshold option' do
        expect(guard.options[:lines_threshold]).to eql 80
      end
    end

    context 'without the jasmine url' do
      it 'sets the jasmine gem url' do
        guard = Guard::Jasmine.new(server: :jasmine_gem, port:   4321)
        expect(guard.options[:jasmine_url]).to eql 'http://localhost:4321/'
      end

      context 'sets the url automatically' do
        context 'with JasmineRails module available' do
          before do
            stub_const 'JasmineRails', Module.new
          end

          it 'it sets the proper jasmine-rails url by default' do
            guard = Guard::Jasmine.new(server: :thin, port: 4321)
            expect(guard.options[:jasmine_url]).to eql 'http://localhost:4321/specs'
          end
        end

        context 'without JasmineRails module available' do
          it 'it sets the jasminerice url by default' do
            guard = Guard::Jasmine.new(server: :thin, port: 4321)
            expect(guard.options[:jasmine_url]).to eql 'http://localhost:4321/jasmine'
          end
        end
      end

      it 'sets the jasmine runner url as configured' do
        guard = Guard::Jasmine.new(server: :thin, port: 4321, server_mount: '/foo')
        expect(guard.options[:jasmine_url]).to eql 'http://localhost:4321/foo'
      end
    end

    context 'with run all options' do
      let(:guard) { Guard::Jasmine.new(run_all: { test: true }) }

      it 'removes them from the default options' do
        expect(guard.options[:run_all]).to be_nil
      end

      it 'saves the run_all options' do
        expect(guard.run_all_options).to eql(test: true)
      end
    end

    context 'with a port but no jasmine_url option set' do
      let(:guard) { Guard::Jasmine.new(port: 4321) }

      it 'sets the port on the jasmine_url' do
        expect(guard.options[:jasmine_url]).to eql 'http://localhost:4321/jasmine'
      end
    end

    context 'without a port but no jasmine_url option set' do
      it 'sets detected free server port on the jasmine_url' do
        expect(Guard::Jasmine).to receive(:find_free_server_port).and_return 7654
        guard = Guard::Jasmine.new
        expect(guard.options[:jasmine_url]).to eql 'http://localhost:7654/jasmine'
      end
    end

    context 'with illegal options' do
      let(:guard) { Guard::Jasmine.new(defaults.merge(specdoc: :wrong, server: :unknown)) }

      it 'sets default :specdoc option' do
        expect(guard.options[:specdoc]).to eql :failure
      end
    end
  end

  describe '.start' do
    context 'without a valid PhantomJS executable' do
      before do
        allow(Guard::Jasmine).to receive(:phantomjs_bin_valid?).and_return false
      end

      it 'throws :task_has_failed' do
        expect { guard.start }.to raise_error(/task_has_failed/)
      end
    end

    context 'with a valid PhantomJS executable' do
      let(:guard) { Guard::Jasmine.new(phantomjs_bin: '/bin/phantomjs') }

      before do
        allow(::Guard::Jasmine).to receive(:phantomjs_bin_valid?).and_return true
      end

      context 'with the server set to :none' do
        before { guard.options[:server] = :none }

        it 'does not start a server' do
          expect(server).not_to receive(:start)
          guard.start
        end
      end

      context 'with the server set to something other than :none' do
        before do
          guard.options[:server]     = :jasmine_gem
          guard.options[:server_env] = 'test'
          guard.options[:port]       = 3333
        end

        it 'does start a server' do
          expect(server).to receive(:start).with(hash_including(server:        :jasmine_gem,
                                                                port:          3333,
                                                                server_env:    'test',
                                                                spec_dir:      'spec',
                                                                rackup_config: nil))
          guard.start
        end
      end

      context 'with :all_on_start set to true' do
        let(:guard) { Guard::Jasmine.new(all_on_start: true) }

        context 'with the Jasmine runner available' do
          before do
            allow(::Guard::Jasmine).to receive(:runner_available?).and_return true
          end

          it 'triggers .run_all' do
            expect(guard).to receive(:run_all)
            guard.start
          end
        end

        context 'without the Jasmine runner available' do
          before do
            allow(::Guard::Jasmine).to receive(:runner_available?).and_return false
          end

          it 'does not triggers .run_all' do
            expect(guard).not_to receive(:run_all)
            guard.start
          end
        end
      end

      context 'with :all_on_start set to false' do
        let(:guard) { Guard::Jasmine.new(all_on_start: false) }

        before do
          allow(::Guard::Jasmine).to receive(:runner_available?).and_return true
        end

        it 'does not trigger .run_all' do
          expect(guard).not_to receive(:run_all)
          guard.start
        end
      end
    end
  end

  describe '.stop' do
    context 'with a configured server' do
      let(:guard) { Guard::Jasmine.new(server: :thin) }

      it 'stops the server' do
        expect(server).to receive(:stop)
        guard.stop
      end
    end

    context 'without a configured server' do
      let(:guard) { Guard::Jasmine.new(server: :none) }

      it 'does not stop the server' do
        expect(server).not_to receive(:stop)
        guard.stop
      end
    end
  end

  describe '.reload' do
    before do
      guard.last_run_failed   = true
      guard.last_failed_paths = ['spec/javascripts/a.js.coffee']
    end

    it 'sets last run failed to false' do
      guard.reload
      expect(guard.last_run_failed).to eql false
    end

    it 'sets last failed paths to empty' do
      guard.reload
      expect(guard.last_failed_paths).to be_empty
    end
  end

  describe '.run_all' do
    let(:options) { defaults.merge(phantomjs_bin: '/bin/phantomjs') }
    let(:guard) { Guard::Jasmine.new(options) }

    context 'without a specified spec dir' do
      it 'starts the Runner with the default spec dir' do
        expect_any_instance_of(runner).to receive(:run).with(['spec']).and_return({})

        guard.run_all
      end
    end

    context 'with a specified spec dir' do
      let(:options) { defaults.merge(phantomjs_bin: '/bin/phantomjs', spec_dir: 'specs') }
      let(:guard) { Guard::Jasmine.new(options) }

      it 'starts the Runner with the default spec dir' do
        expect_any_instance_of(runner).to receive(:run).with(['specs']).and_return({})

        guard.run_all
      end
    end

    context 'with run all options' do
      let(:guard) { Guard::Jasmine.new(run_all: { specdoc: :overwritten }) }

      it 'starts the Runner with the merged run all options' do
        expect(guard.runner.options[:specdoc]).to eql(:overwritten)
        expect_any_instance_of(runner).to receive(:run).with(['spec']).and_return({})
        guard.run_all
      end
    end

    context 'with all specs passing' do
      before do
        guard.last_failed_paths = ['spec/javascripts/a.js.coffee']
        guard.last_run_failed   = true
        expect_any_instance_of(runner).to receive(:run).and_return({})
      end

      it 'sets the last run failed to false' do
        guard.run_all
        expect(guard.last_run_failed).to eql false
      end

      it 'clears the list of failed paths' do
        guard.run_all
        expect(guard.last_failed_paths).to be_empty
      end
    end

    context 'with failing specs' do
      before do
        expect_any_instance_of(runner).to receive(:run).and_return('a_spec_file' => ['had an error'])
      end

      it 'throws :task_has_failed' do
        expect { guard.run_all }.to raise_error(/task_has_failed/)
      end
    end
  end

  describe '.run_on_modifications' do
    let(:options) { defaults.merge(phantomjs_bin: '/Users/michi/.bin/phantomjs') }
    let(:guard) { Guard::Jasmine.new(options) }

    it 'returns false when no valid paths are passed' do
      expect(inspector).to receive(:clean).and_return []
      guard.run_on_modifications(['spec/javascripts/b.js.coffee'])
    end

    it 'starts the Runner with the cleaned files' do
      expect(inspector).to receive(:clean).with(['spec/javascripts/a.js.coffee',
                                                 'spec/javascripts/b.js.coffee'], kind_of(Hash)).and_return ['spec/javascripts/a.js.coffee']

      expect_any_instance_of(runner).to receive(:run).with(['spec/javascripts/a.js.coffee']).and_return({})

      guard.run_on_modifications(['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js.coffee'])
    end

    context 'with :clean enabled' do
      let(:options) { defaults.merge(clean: true, phantomjs_bin: '/usr/bin/phantomjs') }
      let(:guard) { Guard::Jasmine.new(options) }

      it 'passes the paths to the Inspector for cleanup' do
        expect(inspector).to receive(:clean).with(['spec/javascripts/a.js.coffee',
                                                   'spec/javascripts/b.js.coffee'], kind_of(Hash))

        guard.run_on_modifications(['spec/javascripts/a.js.coffee',
                                    'spec/javascripts/b.js.coffee'])
      end
    end

    context 'with :clean disabled' do
      let(:options) { defaults.merge(clean: false, phantomjs_bin: '/usr/bin/phantomjs') }
      let(:guard) { Guard::Jasmine.new(options) }

      it 'does not pass the paths to the Inspector for cleanup' do
        expect(inspector).not_to receive(:clean).with(['spec/javascripts/a.js.coffee',
                                                       'spec/javascripts/b.js.coffee'], kind_of(Hash))

        guard.run_on_modifications(['spec/javascripts/a.js.coffee',
                                    'spec/javascripts/b.js.coffee'])
      end
    end

    context 'with :keep_failed enabled' do
      let(:options) { defaults.merge(keep_failed: true, phantomjs_bin: '/usr/bin/phantomjs') }
      let(:guard) { Guard::Jasmine.new(options) }

      before do
        guard.last_failed_paths = ['spec/javascripts/b.js.coffee']
      end

      it 'passes the paths to the Inspector for cleanup' do
        expect(inspector).to receive(:clean).with(['spec/javascripts/a.js.coffee',
                                                   'spec/javascripts/b.js.coffee'], kind_of(Hash))

        guard.run_on_modifications(['spec/javascripts/a.js.coffee'])
      end

      it 'appends the last failed paths to the current run' do
        expect(guard.runner).to receive(:run)
          .with(['spec/javascripts/a.js.coffee',
                 'spec/javascripts/b.js.coffee'])
          .and_return('spec/javascripts/b.js.coffee' => ['failure'])

        expect(guard.last_failed_paths).to include('spec/javascripts/b.js.coffee')
        expect(guard.last_failed_paths).to_not include('spec/javascripts/a.js.coffee')

        expect { guard.run_on_modifications(['spec/javascripts/a.js.coffee']) }.to raise_error(/task_has_failed/)
      end
    end

    context 'with only success specs' do
      before do
        guard.last_failed_paths = ['spec/javascripts/a.js.coffee']
        guard.last_run_failed   = true
        expect(guard.runner).to receive(:run).with(kind_of(Array)).and_return({})
      end

      it 'sets the last run failed to false' do
        guard.run_on_modifications(['spec/javascripts/a.js.coffee'])
        expect(guard.last_run_failed).to eql false
      end

      it 'removes the passed specs from the list of failed paths' do
        guard.run_on_modifications(['spec/javascripts/a.js.coffee'])
        expect(guard.last_failed_paths).to be_empty
      end

      context 'when :all_after_pass is enabled' do
        let(:guard) { Guard::Jasmine.new(all_after_pass: true) }

        it 'runs all specs' do
          expect(guard).to receive(:run_all)
          guard.run_on_modifications(['spec/javascripts/a.js.coffee'])
        end
      end

      context 'when :all_after_pass is enabled' do
        let(:guard) { Guard::Jasmine.new(all_after_pass: false) }

        it 'does not run all specs' do
          expect(guard).not_to receive(:run_all)
          guard.run_on_modifications(['spec/javascripts/a.js.coffee'])
        end
      end
    end

    context 'with failing specs' do
      before do
        guard.last_run_failed = false
        expect_any_instance_of(runner).to receive(:run).and_return('spec/javascripts/a.js.coffee' => ['A message failed'])
      end

      it 'throws :task_has_failed' do
        expect { guard.run_on_modifications(['spec/javascripts/a.js.coffee']) }.to raise_error(/task_has_failed/)
      end

      it 'sets the last run failed to true' do
        expect { guard.run_on_modifications(['spec/javascripts/a.js.coffee']) }.to raise_error(/task_has_failed/)
        expect(guard.last_run_failed).to eql true
      end

      it 'appends the failed spec to the list of failed paths' do
        expect { guard.run_on_modifications(['spec/javascripts/a.js.coffee']) }.to throw_symbol :task_has_failed
        expect(guard.last_failed_paths).to include('spec/javascripts/a.js.coffee')
      end
    end
  end
end
