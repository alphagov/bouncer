require 'spec_helper'

describe StatusRenderer do
  subject(:renderer) { StatusRenderer.new }

  describe 'template storage' do
    its([404]) { should be_an(Erubis::EscapedEruby) }
    its([410]) { should be_an(Erubis::EscapedEruby) }
    its([301]) { should be_nil }

    it 'reuses its templates' do
      t1 = renderer[404]
      t2 = renderer[404]

      t1.object_id.should == t2.object_id
    end
  end

  describe 'template rendering' do
    let(:attributes_for_render) do
      {
        title: 'Keeping bees',
        homepage: nil,
        css: nil,
        furl: nil,
        host: nil,
        suggested_url: nil,
        archive_url: nil
      }
    end

    subject(:rendered) { renderer.render(attributes_for_render, 410) }

    it { should include('410 - Page Archived') }
    it { should include('Keeping bees') }
  end
end
