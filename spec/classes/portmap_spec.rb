require 'spec_helper'

describe 'portmap' do

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it { expect { should compile}.to raise_error(/not supported on an Unsupported/) }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}", :compile do
      let(:facts) do
        facts
      end

      it { should contain_class('portmap') }
      it { should contain_class('portmap::install') }
      it { should contain_class('portmap::params') }
      it { should contain_class('portmap::service') }

      case facts[:osfamily]
      when 'Debian'
        it { should contain_package('rpcbind') }
        case facts[:operatingsystem]
        when 'Ubuntu'
          case facts[:operatingsystemrelease]
          when '12.04'
            it { should contain_service('portmap') }
          when '14.04'
            it { should contain_service('rpcbind') }
          else
            it { should contain_service('rpcbind.socket') }
          end
        else
          it { should contain_service('rpcbind') }
        end
      when 'OpenBSD'
        it { should have_package_resource_count(0) }
        it { should contain_service('portmap') }
      when 'RedHat'
        case facts[:operatingsystemmajrelease]
        when '5'
          it { should contain_package('portmap') }
          it { should contain_service('portmap') }
        when '6'
          it { should contain_package('rpcbind') }
          it { should contain_service('rpcbind') }
        else
          it { should contain_package('rpcbind') }
          it { should contain_service('rpcbind.socket') }
        end
      end
    end
  end
end
