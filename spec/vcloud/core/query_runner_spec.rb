require 'spec_helper'

describe Vcloud::Core::QueryRunner do
  before(:each) do
    @mock_fog_interface = StubFogInterface.new
    Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
    @query_runner = Vcloud::Core::QueryRunner.new()
  end

  context '#available_query_types' do

    it 'should return empty array if no query type links are returned from API' do
      @mock_fog_interface.stub(:get_execute_query).and_return({:Link => {}})
      result = @query_runner.available_query_types
      expect(result.size).to eq(0)
    end

    it 'returns queriable entity types provided by the API via :href link elements' do
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {:Link => [
          {:rel  => 'down',
           :href => 'query?type=alice&#38;format=records'},
          {:rel  => 'down',
           :href => 'query?type=bob&#38;format=records'},
          {:rel  => 'down',
           :href => 'query?type=charlie&#38;format=records'},
        ]})
      expect(@query_runner.available_query_types).to eq(['alice', 'bob', 'charlie'])
    end

    it 'should ignore query links with format=references and format=idrecords' do
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {:Link => [
          {:rel  => 'down',
           :href => 'query?type=alice&#38;format=references'},
          {:rel  => 'down',
           :href => 'query?type=bob&#38;format=idrecords'},
          {:rel  => 'down',
           :href => 'query?type=charlie&#38;format=records'},
        ]})
      expect(@query_runner.available_query_types).to eq(['charlie'])
    end

  end

  context '#run' do

    it "should raise an error if a :format option is supplied" do
      expect { @query_runner.run('vApp', :format => 'references') }.
        to raise_error(ArgumentError, "Query API :format option is not supported")
    end

    it 'should return no results when fog returns no results' do
      @mock_fog_interface.stub(:get_execute_query).and_return({})
      expect(@query_runner.run()).to eq([])
    end

    it 'return no results when fog results do not include a "Record" or a "Reference"' do
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleBlob => {:field1 => 'Stuff 1'}
        }
      )
      expect(@query_runner.run().size).to eq(0)
    end

    it 'should return a single result when fog returns a single record' do
      fields = {:field1 => 'Stuff 1'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleRecord => [fields]
        }
      )
      result = @query_runner.run()
      expect(result.size).to eq(1)
      expect(result.first).to eq(fields)
    end

    it 'should return a single result when fog returns a single reference' do
      fields = {:field1 => 'Stuff 1'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleReference => [fields]
        }
      )
      result = @query_runner.run()
      expect(result.size).to eq(1)
      expect(result.first).to eq(fields)
    end

    it 'should wrap single result from fog in list' do
      fields = {:field1 => 'Stuff 1'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleRecord => fields
        }
      )
      result = @query_runner.run()
      expect(result.size).to eq(1)
      expect(result.first).to eq(fields)
    end

    it 'should return all results in a record returned by fog' do
      fields      = {:field1 => 'Stuff 1'}
      more_fields = {:field1 => 'More Stuff 1'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleRecord => [fields, more_fields]
        }
      )
      result = @query_runner.run()
      expect(result.size).to eq(2)
      expect(result[0]).to eq(fields)
      expect(result[1]).to eq(more_fields)
    end

    it 'should return the first item if more than one records provided' do
      fields1 = {:field1 => 'Stuff 1'}
      fields2 = {:field1 => 'Stuff 2'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleRecord => [fields1],
          :WobbleRecord => [fields2]
        }
      )
      result = @query_runner.run()
      expect(result.size).to eq(1)
      expect(result.first).to eq(fields1)
    end

    it 'should raise error if lastPage is not an integer' do
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :lastPage     => :qwerty,
          :WibbleRecord => []
        }
      )

      expect { @query_runner.run() }.to raise_error('Invalid lastPage (qwerty) in query results')
    end

    it 'should get each page and collect the results' do
      fields = {:field1 => 'Stuff 1'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :lastPage     => 2,
          :WibbleRecord => [fields]
        }
      )
      result = @query_runner.run()
      expect(result.size).to eq(2)
      expect(result[0]).to eq(fields)
      expect(result[1]).to eq(fields)
    end

  end
end
