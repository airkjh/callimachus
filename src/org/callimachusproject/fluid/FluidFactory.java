package org.callimachusproject.fluid;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.xml.transform.TransformerConfigurationException;

import org.callimachusproject.fluid.consumers.BooleanMessageWriter;
import org.callimachusproject.fluid.consumers.ByteArrayMessageWriter;
import org.callimachusproject.fluid.consumers.ByteArrayStreamMessageWriter;
import org.callimachusproject.fluid.consumers.DOMMessageWriter;
import org.callimachusproject.fluid.consumers.DatatypeWriter;
import org.callimachusproject.fluid.consumers.DocumentFragmentMessageWriter;
import org.callimachusproject.fluid.consumers.FormMapMessageWriter;
import org.callimachusproject.fluid.consumers.FormStringMessageWriter;
import org.callimachusproject.fluid.consumers.GraphMessageWriter;
import org.callimachusproject.fluid.consumers.HttpMessageWriter;
import org.callimachusproject.fluid.consumers.InputStreamBodyWriter;
import org.callimachusproject.fluid.consumers.ModelMessageWriter;
import org.callimachusproject.fluid.consumers.PrimitiveBodyWriter;
import org.callimachusproject.fluid.consumers.RDFObjectURIWriter;
import org.callimachusproject.fluid.consumers.ReadableBodyWriter;
import org.callimachusproject.fluid.consumers.ReadableByteChannelBodyWriter;
import org.callimachusproject.fluid.consumers.StringBodyWriter;
import org.callimachusproject.fluid.consumers.TupleMessageWriter;
import org.callimachusproject.fluid.consumers.URIListWriter;
import org.callimachusproject.fluid.consumers.XMLEventMessageWriter;
import org.callimachusproject.fluid.producers.BooleanMessageReader;
import org.callimachusproject.fluid.producers.ByteArrayMessageReader;
import org.callimachusproject.fluid.producers.ByteArrayStreamMessageReader;
import org.callimachusproject.fluid.producers.DOMMessageReader;
import org.callimachusproject.fluid.producers.DatatypeReader;
import org.callimachusproject.fluid.producers.DocumentFragmentMessageReader;
import org.callimachusproject.fluid.producers.FormMapMessageReader;
import org.callimachusproject.fluid.producers.FormStringMessageReader;
import org.callimachusproject.fluid.producers.GraphMessageReader;
import org.callimachusproject.fluid.producers.HttpMessageReader;
import org.callimachusproject.fluid.producers.InputStreamBodyReader;
import org.callimachusproject.fluid.producers.ModelMessageReader;
import org.callimachusproject.fluid.producers.NetURIReader;
import org.callimachusproject.fluid.producers.PrimitiveBodyReader;
import org.callimachusproject.fluid.producers.RDFObjectURIReader;
import org.callimachusproject.fluid.producers.ReadableBodyReader;
import org.callimachusproject.fluid.producers.ReadableByteChannelBodyReader;
import org.callimachusproject.fluid.producers.StringBodyReader;
import org.callimachusproject.fluid.producers.StringURIReader;
import org.callimachusproject.fluid.producers.TupleMessageReader;
import org.callimachusproject.fluid.producers.URIReader;
import org.callimachusproject.fluid.producers.URLReader;
import org.callimachusproject.fluid.producers.XMLEventMessageReader;
import org.openrdf.model.URI;
import org.openrdf.repository.object.ObjectConnection;

public class FluidFactory {
	private static final FluidFactory instance = new FluidFactory();
	static {
		instance.init();
	}

	public static FluidFactory getInstance() {
		return instance;
	}

	private List<Consumer> consumers = new ArrayList<Consumer>();
	private List<Producer> producers = new ArrayList<Producer>();
	private void init() {
		consumers.add(new RDFObjectURIWriter());
		consumers.add(new BooleanMessageWriter());
		consumers.add(new ModelMessageWriter());
		consumers.add(new GraphMessageWriter());
		consumers.add(new TupleMessageWriter());
		consumers.add(new DatatypeWriter());
		consumers.add(new StringBodyWriter());
		consumers.add(new PrimitiveBodyWriter());
		consumers.add(new HttpMessageWriter());
		consumers.add(new InputStreamBodyWriter());
		consumers.add(new ReadableBodyWriter());
		consumers.add(new ReadableByteChannelBodyWriter());
		consumers.add(new XMLEventMessageWriter());
		consumers.add(new ByteArrayMessageWriter());
		consumers.add(new ByteArrayStreamMessageWriter());
		consumers.add(new DOMMessageWriter());
		consumers.add(new FormMapMessageWriter());
		consumers.add(new FormStringMessageWriter());
		consumers.add(new URIListWriter(String.class));
		consumers.add(new URIListWriter(URI.class));
		consumers.add(new URIListWriter(URL.class));
		consumers.add(new URIListWriter(java.net.URI.class));
		try {
			consumers.add(new DocumentFragmentMessageWriter());
		} catch (TransformerConfigurationException e) {
			throw new AssertionError(e);
		}
		producers.add(new URIReader());
		producers.add(new URLReader());
		producers.add(new StringURIReader());
		producers.add(new NetURIReader());
		producers.add(new RDFObjectURIReader());
		producers.add(new ModelMessageReader());
		producers.add(new GraphMessageReader());
		producers.add(new TupleMessageReader());
		producers.add(new BooleanMessageReader());
		producers.add(new DatatypeReader());
		producers.add(new StringBodyReader());
		producers.add(new PrimitiveBodyReader());
		producers.add(new FormMapMessageReader());
		producers.add(new FormStringMessageReader());
		producers.add(new HttpMessageReader());
		producers.add(new InputStreamBodyReader());
		producers.add(new ReadableBodyReader());
		producers.add(new ReadableByteChannelBodyReader());
		producers.add(new XMLEventMessageReader());
		producers.add(new ByteArrayMessageReader());
		producers.add(new ByteArrayStreamMessageReader());
		producers.add(new DOMMessageReader());
		producers.add(new DocumentFragmentMessageReader());
	}

	public FluidBuilder builder(ObjectConnection con) {
		return new FluidBuilder(consumers, producers, con);
	}

}
