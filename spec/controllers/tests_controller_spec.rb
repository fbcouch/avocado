describe TestsController do
  context 'when requests SHOULD be documented' do
    around do |example|
      Avocado.reset!
      expect { example.run }.to change { Avocado.payload.size }.from(0).to(1)
    end

    it 'stores JSON requests in Avocado' do
      get :json
    end
  end

  context 'when requests should NOT be documented' do
    around do |example|
      Avocado.reset!
      example.run
      Avocado.payload.should == []
    end

    it 'does not store non-JSON requests' do
      get :text
    end

    it 'does not store when document: false', document: false do
      get :json
    end

    it 'does not store when document_if returns false' do
      Avocado::Config.document_if = -> { false }
      get :json
    end
  end

  describe 'Avocado.payload' do
    around do |example|
      Avocado.reset!
      example.run
      assertion.call
    end

    context 'with params' do
      let(:assertion) do
        -> { Avocado.payload.first[:request][:params].should == { 'parameter' => '123' } }
      end

      it 'should have sent the params' do
        get :json, parameter: 123
      end
    end

    context 'with headers' do
      let(:assertion) do
        -> { Avocado.payload.first[:request][:headers].should == { 'X-Example-Header' => 123 } }
      end

      it 'should send the header' do
        @request.headers['X-Example-Header'] = 123
        Avocado::Config.headers = ['X-Example-Header']
        get :json, nil
      end
    end

  end
end