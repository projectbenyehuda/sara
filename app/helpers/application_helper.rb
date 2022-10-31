module ApplicationHelper
  def options_from_query(tag)
    query = @browsing_tree['filters']['wikidata'].find{|f| f['tag'] == tag}['lookup_query']
    if query.present?
      @sparql_results = wikidata_query_as_hash(query)
      opts = []
      @sparql_results.each do |item|
        opts << [item[0], item[1]]
      end
    end
  end
  def textify_media_type(mtype)
    case mtype
    when 'text'
      return t(:text)
    when 'image'
      return t(:image)
    when 'audio'
      return t(:audio)
    when 'video'
      return t(:video)
    when 'map'
      return t(:map)
    when 'archive'
      return t(:archive)
    else
      return t(:unknown)
    end
  end
  def textify_source(source)
    case source
    when 'wikipedia'
      return t(:wikipedia)
    when 'nli'
      return t(:nli)
    when 'pby'
      return t(:pby)
    when 'wikidata'
      return t(:wikidata)
    else
      return t(:unknown)
    end
  end
  def image_for_media_type(mtype)
    case mtype
    when 'text'
      return '/assets/text item_pic.png'
    when 'image'
      return '/assets/picture_pic.png'
    #when 'audio'
    #  return 'audio.png'
    when 'video'
      return '/assets/video_pic.png'
    #when 'map'
    #  return 'map.png'
    when 'archive'
      return '/assets/archive item_pic.png'
    else
      return ''
    end
  end
  def image_for_source(source)
    case source
    when 'wikipedia'
      return '/assets/wikipedia_logo_24.png'
    when 'nli'
      return '/assets/nli_logo_24.png'
    when 'pby'
      return '/assets/pby_logo_24.png'
    when 'wikidata'
      return '/assets/wikidata_logo_24.png'
    else
      return ''
    end
  end
end
